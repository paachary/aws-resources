#!/bin/ksh

## Script for invoking the create data pipeline aws cli command based on the parameters / arguments 
## passed to the script
## Author : Prashant Acharya
## Usage:
## create-update-stack [options]
## options:
##  -b --bucket-name   : s3 bucket name which contains the scripts and input files (name without s3://). [required]
##  -k --key-name      : emr Key Name needed for connecting to the emr cluster instanes [required]
##  -n --function-name : lambda function name which will be attached to the s3 bucket. [required]
##  -t --table-name    : dynamodb table name which will be populated by the lambda function [required]
##  -h --help

##***
## Usage

usage()
{
    echo "usage: create-update-stack [options]
                options:
                    -b --bucket-name   : s3 bucket name which contains the scripts and input files (name without s3://). [required]
                    -k --key-name      : emr Key Name needed for connecting to the emr cluster instanes [required]
                    -n --function-name : lambda function name which will be attached to the s3 bucket. [required]
                    -t --table-name    : dynamodb table name which will be populated by the lambda function [required]
                    -h --help
    "
}

while [ "$1" != "" ]; do
    case $1 in
        -b | --bucket-name )     shift
                                 BUCKET_NAME=$1
                                 ;;
        -k | --key-name )        shift
                                 EMRKEYPAIR=$1
                                 ;;              
        -n | --function-name )   shift
                                 FUNCTION_NAME=$1
                                 ;;
        -t | --table-name )      shift
                                 DDB_TABLE_NAME=$1
                                 ;;                    
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z ${BUCKET_NAME} ] | [ -z ${EMRKEYPAIR} ] | [ -z ${FUNCTION_NAME} ] | [ -z ${DDB_TABLE_NAME} ]
then
    usage
    exit 1
fi

PROPERTIES_FILE="$HOME/DataPipeLineProperties.json"
BUCKET="s3://${BUCKET_NAME}"

echo $BUCKET
echo $EMRKEYPAIR
echo $PROPERTIES_FILE
echo ${FUNCTION_NAME} 
echo ${DDB_TABLE_NAME}

ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | tr -d '"'`
echo $ACCOUNT_ID

REGION=`aws configure list | grep region| awk '{print $2}'`
echo $REGION

##***********************
## Define the user-defined functions to setup the environment

create_DataPipeLinePropertiesFile_from_Template()
{
    if test -f "$PROPERTIES_FILE"; then
        echo "$PROPERTIES_FILE file exists. Deleting..."
        rm -f "$PROPERTIES_FILE"
    fi
    
    cp /home/hadoop/aws-resources/scripts/aws_data_pipeline/DataPipeLinePropertiesTemplate.json  $PROPERTIES_FILE
}


create_ec2_keyPair()
{
    if test -f "$HOME/${EMRKEYPAIR}.pem"; then
        echo "$HOME/${EMRKEYPAIR}.pem file exists. Deleting..."
        rm -f "$HOME/${EMRKEYPAIR}.pem"
    fi
    
    response=`aws ec2 delete-key-pair --key-name ${EMRKEYPAIR}`
       
    ## Script to create the ec2 keypair to be used in the emr cluster creation process

    keypair=`aws ec2 create-key-pair --key-name ${EMRKEYPAIR}`

    echo $keypair | jq '.KeyMaterial' | tr -d '"' > $HOME/${EMRKEYPAIR}.pem

    # Replacing keypair with valid keypair
    sed -i -e 's/EMRKP/"'"${EMRKEYPAIR}"'"/' $PROPERTIES_FILE
}

fetch_current_aws_region()
{
    ## Script to fetch the current aws region configured using the aws configure

    REGION=`aws configure list | grep region| awk '{print $2}'`
    echo $REGION

    # Replacing region with valid region
    sed -i -e 's/REGION/"'"${REGION}"'"/' $PROPERTIES_FILE
}

fetch_1st_public_subnet_id()
{
    ## Script to fetch the fist available public subnet id to be passed on to the emr cluster

    SUBNETID=`aws ec2 describe-subnets | jq '.Subnets[0] | select(.State == "available" and .MapPublicIpOnLaunch == true) | .SubnetId'| tr -d '"'`
    echo "subnetid = ${SUBNETID}"

    # Replacing subnet with valid subnet
    sed -i -e 's/SUBNETID/"'"${SUBNETID}"'"/' $PROPERTIES_FILE
}

update_s3_bucket_name()
{
    # Replacing s3 bucket name with valid name
    echo "Replacing the S3 Bucket name in the file"
    
    sed -i -e 's/S3BUCKETNAME/"'"s3\:\/\/${BUCKET_NAME}"'"/' $PROPERTIES_FILE
}

copy_contents_2_s3_bucket()
{
    # Creating the bucket
    echo "creating the bucket -> ${BUCKET}"
    
    response=`aws s3 mb ${BUCKET}`
    echo $response
    
    response=`aws s3 cp /home/hadoop/aws-resources/scripts/aws_emr_spark/ ${BUCKET}/scripts/ --recursive --exclude "*.json" --exclude "*.ksh" --exclude "*.txt"`
    echo $response
    
    response=`aws s3 cp /home/hadoop/dataset/ml-100k/data/ ${BUCKET}/input/ --recursive`
    echo $response
}


create_lambda_role()
{
    POLICY_FILE=$HOME/trust_policy.json
    
    rm -f $POLICY_FILE
    
    cp /home/hadoop/aws-resources/scripts/aws_lambda/trust_policy.json $POLICY_FILE
    
    response=`aws iam create-role --role-name lambda-exec --assume-role-policy-document file://$POLICY_FILE`
    
    roleArn=`echo $response | jq '.Role.Arn' | tr -d '"'`
    
    echo $roleArn
    
    sleep 30

}

attach_execution_roles_2_lambda_role()
{
    echo "Attaching the BasicExecution for Lambda role"
    
    # Attaching the BasicExecution for Lambda
    response=`aws iam attach-role-policy --role-name lambda-exec \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`

    echo $response

     echo "Attaching the Full access on S3 for Lambda role"
        
    # Attaching the AmazonS3FullAccess for Lambda
    response=`aws iam attach-role-policy --role-name lambda-exec \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess`

    echo $response
    
    echo "Attaching the Full access on Dynamodb for Lambda role"
        
    # Attaching the AmazonDynamoDBFullAccess for Lambda
    response=`aws iam attach-role-policy --role-name lambda-exec \
    --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess`

    echo $response
}

create_lambda_function()
{    

    roleArn="arn:aws:iam::${ACCOUNT_ID}:role/lambda-exec"
    
    # Zipping the python lamdba code.
       
    cp /home/hadoop/aws-resources/scripts/aws_lambda/load_json_from_s3_2_dynamodb.py ${FUNCTION_NAME}.py    
    
    rm -f function.zip
    
    zip function.zip ${FUNCTION_NAME}.py

    # Creating the lamdba function
    response=`aws lambda create-function \
    --function-name ${FUNCTION_NAME} \
    --zip-file fileb://function.zip \
    --handler ${FUNCTION_NAME}.lambda_handler \
    --runtime python3.7 \
    --environment Variables={DDB_NAME="'"${DDB_TABLE_NAME}"'"} \
    --role $roleArn`

    lamdaArn=`echo $response | jq '.FunctionArn' | tr -d '"'`
    
    echo $lamdaArn
    
    echo "Enabling S3 to invoke lambda function"
    
    response=`aws lambda add-permission --function-name ${FUNCTION_NAME} --principal s3.amazonaws.com \
    --statement-id s3invoke --action "lambda:InvokeFunction" \
    --source-arn arn:aws:s3:::${BUCKET_NAME} \
    --source-account ${ACCOUNT_ID}`    
}

attach_lamdba_2_s3()
{
    lambdaARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${FUNCTION_NAME}"
    
    echo "Attaching the lambda to S3 event"

   
    # Attaching the lambda to S3 event
    
    CONFIG_FILE=$HOME/lambdaConfigurations.json
    
    rm -f $CONFIG_FILE
    
    cp /home/hadoop/aws-resources/scripts/aws_lambda/lambdaConfigurationsTemplate.json $CONFIG_FILE
    
    sed -i -e 's/LAMBDA_FUNCTION_ARN/"'"${lambdaARN}"'"/' $CONFIG_FILE
    
    response=`aws s3api put-bucket-notification-configuration --bucket ${BUCKET_NAME} --notification-configuration file://$CONFIG_FILE`
}
    

create_ddb_table()
{
    table=$1
    
    echo "Creating dynamodb table $table"
      
    # Creating the dynamodb table.
    table=`aws dynamodb create-table --table-name ${table} \
    --attribute-definitions AttributeName=genre,AttributeType=S \
    --key-schema AttributeName=genre,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5`

    tableArn=`echo $table | jq '.TableDescription.TableArn' | tr -d '"'`
    
    echo $tableArn
}

##***********************

## Invoking the user defined functions for setting up the environment

echo "Starting invocation of functions"

copy_contents_2_s3_bucket

create_lambda_role

attach_execution_roles_2_lambda_role

create_lambda_function

attach_lamdba_2_s3

create_ddb_table ${DDB_TABLE_NAME}

create_DataPipeLinePropertiesFile_from_Template

create_ec2_keyPair

fetch_current_aws_region

fetch_1st_public_subnet_id

update_s3_bucket_name


##***************************
## Creating the aws data pipeline using the aws cli commands

# Creating default roles
echo "Creating default roles"
response=`aws datapipeline create-default-roles`
#echo $response

# Create the data pipeline
response=`aws datapipeline create-pipeline --name emrClusterPipeline --unique-id emr_token`
echo $response

pipelineid=`echo $response | jq '.pipelineId' | tr -d '"'`
echo $pipelineid

# Upload your pipeline definition
echo "Uploading the pipeline definition"
response=`aws datapipeline put-pipeline-definition --pipeline-id $pipelineid --pipeline-definition file://${PROPERTIES_FILE}`

errors=`echo $response | jq '.validationErrors[]'`
echo $errors

warnings=`echo $response | jq '.validationWarnings[]'`
echo $warnings


# Activate the pipeline
echo "Activating the pipeline"
response=`aws datapipeline activate-pipeline --pipeline-id $pipelineid`
echo $response

# List the pipelines
response=`aws datapipeline list-pipelines`

##**************************************
