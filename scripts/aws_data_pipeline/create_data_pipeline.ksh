#!/bin/ksh

## Script for invoking the create data pipeline aws cli command based on the parameters / arguments 
## passed to the script
## Author : Prashant Acharya
## Usage:
## create_data_pipeline.ksh [options]
## options:
## -b --bucket-name            :s3 bucket name which contains the scripts and input files (name without s3://). [required]
## -k --key-name               :emr Key Name needed for connecting to the emr cluster instanes [required]
## -d --es_domain_name         :elasticsearch domain name [Required] [The name must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9, and - (hyphen).]
## -n --function-name-1        :lambda function name which will be attached to s3 bucket. [Optional] [Default=movie_genre_func]
## -f --function-name-2        :lambda function name which will be attached to s3 bucket. [Optional] [Default=occupation_movie_genre_func]
## -g --genre-table-name       :dynamodb genre table name which will be populated by the lambda function [Optional] [Default=movies_genres]
## -o --occup_genre-table-name :dynamodb occupation genre table name which will be populated by the lambda function [Optional] [Default=occupation_movies_genres]
## -h --help

##***
## Usage

usage()
{
    echo "usage: create_data_pipeline.ksh [options]
 options:
-b --bucket-name            :s3 bucket name which contains the scripts and input files (name without s3://). [Required]

-k --key-name               :emr Key Name needed for connecting to the emr cluster instanes [Required]

-d --es_domain_name         :elasticsearch domain name [Required] [The name must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9, and - (hyphen).]

-n --function-name-1        :lambda function name which will be attached to s3 bucket. [Optional] [Default=movie_genre_func]

-f --function-name-2        :lambda function name which will be attached to s3 bucket. [Optional] [Default=occupation_movie_genre_func]

-g --genre-table-name       :dynamodb genre table name which will be populated by the lambda function [Optional] [Default=movies_genres]

-o --occup_genre-table-name :dynamodb occupation genre table name which will be populated by the lambda function [Optional] [Default=occupation_movies_genres]

-h --help
    "
}

while [ "$1" != "" ]; do
    case $1 in
        -b | --bucket-name )           shift
                                       BUCKET_NAME=$1
                                       ;;
        -k | --key-name )              shift
                                       EMRKEYPAIR=$1
                                       ;;
        -d | --es-domain-name )        shift
                                       ES_DOMAIN_NAME=$1
                                       ;;
        -n | --function-name-1 )       shift
                                       MOVIE_GENRE_FUNC=$1
                                       ;;
        -f | --function-name-2 )       shift
                                       OCCUP_MOVIE_GENRE_FUNC=$1
                                       ;;
        -g | --genre-table-name )      shift
                                       DDB_GENRE_TABLE_NAME=$1
                                       ;;                    
        -o | --occp_genre-table-name ) shift
                                       DDB_OCCP_GENRE_TABLE_NAME=$1
                                       ;;                    
        -h | --help )                  usage
                                       exit
                                       ;;
        * )                            usage
                                       exit 1
    esac
    shift
done

if [ -z ${ES_DOMAIN_NAME} ]
then
    usage
    exit 1
fi

if [ -z ${BUCKET_NAME} ]
then
    usage
    exit 1
fi

if [ -z ${EMRKEYPAIR} ]
then
    usage
    exit 1
fi

if [ -z ${MOVIE_GENRE_FUNC} ]
then
    MOVIE_GENRE_FUNC="movie_genre_func"
fi

if [ -z ${OCCUP_MOVIE_GENRE_FUNC} ]
then
    OCCUP_MOVIE_GENRE_FUNC="occupation_movie_genre_func"
fi

if [ -z ${DDB_GENRE_TABLE_NAME} ]
then
    DDB_GENRE_TABLE_NAME="movies_genres"
fi

if [ -z ${DDB_OCCP_GENRE_TABLE_NAME} ]
then
    DDB_OCCP_GENRE_TABLE_NAME="occupation_movies_genres"
fi

PROPERTIES_FILE="/tmp/DataPipeLineProperties.json"
BUCKET="s3://${BUCKET_NAME}"

echo ${BUCKET}
echo ${EMRKEYPAIR}
echo ${ES_DOMAIN_NAME}
echo $PROPERTIES_FILE
echo ${MOVIE_GENRE_FUNC} 
echo ${OCCUP_MOVIE_GENRE_FUNC} 
echo ${DDB_GENRE_TABLE_NAME}
echo ${DDB_OCCP_GENRE_TABLE_NAME}

ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | tr -d '"'`
echo ${ACCOUNT_ID}

REGION=`aws configure list | grep region| awk '{print $2}'`
echo ${REGION}
sleep 30

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
    if test -f "/tmp/${EMRKEYPAIR}.pem"; then
        echo "/tmp/${EMRKEYPAIR}.pem file exists. Deleting..."
        rm -f "/tmp/${EMRKEYPAIR}.pem"
    fi
    
    response=`aws ec2 delete-key-pair --key-name ${EMRKEYPAIR}`
       
    ## Script to create the ec2 keypair to be used in the emr cluster creation process

    keypair=`aws ec2 create-key-pair --key-name ${EMRKEYPAIR}`

    echo $keypair | jq '.KeyMaterial' | tr -d '"' > /tmp/${EMRKEYPAIR}.pem

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
    
    response=`aws s3 cp /home/hadoop/aws-resources/scripts/aws_emr_spark/pyspark/ ${BUCKET}/scripts/ --recursive --exclude "*.json" --exclude "*.ksh" --exclude "*.txt"`
    echo $response
    
    response=`aws s3 cp /home/hadoop/aws-resources/scripts/aws_emr_spark/scala/MovieLensUserPreferedMovies/moviedataset.jar ${BUCKET}/jar/`
    echo $response

    response=`aws s3 cp /home/hadoop/dataset/ml-100k/data/ ${BUCKET}/input/ --recursive`
    echo $response
}

create_lambda_role()
{
    POLICY_FILE=/tmp/trust_policy.json
    
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
    response=`aws iam attach-role-policy --role-name lambda-exec --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`

    echo $response

     echo "Attaching the Full access on S3 for Lambda role"
        
    # Attaching the AmazonS3FullAccess for Lambda
    response=`aws iam attach-role-policy --role-name lambda-exec --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess`

    echo $response
    
    echo "Attaching the Full access on Dynamodb for Lambda role"
        
    # Attaching the AmazonDynamoDBFullAccess for Lambda
    response=`aws iam attach-role-policy --role-name lambda-exec --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess`

    echo $response
}

create_lambda_function()
{
    function_name=$1
    table_name=$2
    
    echo "Lambda Function name - $function_name"
    echo "Dynamo DB table name - $table_name"
    
    roleArn="arn:aws:iam::${ACCOUNT_ID}:role/lambda-exec"
    
    # Zipping the python lamdba code.
       
    cp /home/hadoop/aws-resources/scripts/aws_lambda/load_json_from_s3_2_dynamodb.py ${function_name}.py
    
    rm -f function.zip
    
    zip function.zip ${function_name}.py

    # Creating the lamdba function
    response=`aws lambda create-function \
    --function-name ${function_name} \
    --zip-file fileb://function.zip \
    --handler ${function_name}.lambda_handler \
    --runtime python3.7 \
    --environment Variables={DDB_NAME="'"${table_name}"'"} \
    --role $roleArn`

    lamdaArn=`echo $response | jq '.FunctionArn' | tr -d '"'`

    echo $lamdaArn

    echo "Enabling S3 to invoke lambda function"

    response=`aws lambda add-permission --function-name ${function_name} \
    --principal s3.amazonaws.com \
    --statement-id s3invoke --action "lambda:InvokeFunction" \
    --source-arn arn:aws:s3:::${BUCKET_NAME} \
    --source-account ${ACCOUNT_ID}`

    rm -fr function.zip
}

attach_lamdba_func_2_s3()
{
    lambdaARN_1=$1
    PREFIX_VALUE_1=$2
    FUNCTION_NAME_1=$3

    lambdaARN_2=$4
    PREFIX_VALUE_2=$5
    FUNCTION_NAME_2=$6

    
    echo "Attaching the lambda to S3 event"

    # Attaching the lambda to S3 event
    
    CONFIG_FILE=/tmp/lambdaConfigurations.json
    
    rm -f $CONFIG_FILE
    
    cp /home/hadoop/aws-resources/scripts/aws_lambda/lambdaConfigurationsTemplate.json $CONFIG_FILE
    
    sed -i -e 's/LAMBDA_FUNCTION_ID_1/"'"${FUNCTION_NAME_1}"'"/' $CONFIG_FILE
    
    sed -i -e 's/PREFIX_VALUE_1/"'"${PREFIX_VALUE_1}"'"/' $CONFIG_FILE

    sed -i -e 's/LAMBDA_FUNCTION_ARN_1/"'"${lambdaARN_1}"'"/' $CONFIG_FILE
    
    sed -i -e 's/LAMBDA_FUNCTION_ID_2/"'"${FUNCTION_NAME_2}"'"/' $CONFIG_FILE
    
    sed -i -e 's/PREFIX_VALUE_2/"'"${PREFIX_VALUE_2}"'"/' $CONFIG_FILE

    sed -i -e 's/LAMBDA_FUNCTION_ARN_2/"'"${lambdaARN_2}"'"/' $CONFIG_FILE
    
    response=`aws s3api put-bucket-notification-configuration --bucket ${BUCKET_NAME} --notification-configuration file://$CONFIG_FILE`
}

create_ddb_table_1()
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

create_ddb_table_2()
{
    table=$1
    
    echo "Creating dynamodb table $table"
      
    # Creating the dynamodb table.
    table=`aws dynamodb create-table --table-name ${table} \
    --attribute-definitions AttributeName=occupation,AttributeType=S AttributeName=genre,AttributeType=S \
    --key-schema AttributeName=occupation,KeyType=HASH AttributeName=genre,KeyType=RANGE \
    --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5`

    tableArn=`echo $table | jq '.TableDescription.TableArn' | tr -d '"'`
    
    echo $tableArn
}

##***********************

## Invoking the user defined functions for setting up the environment

echo "Starting invocation of functions"

# Submitting the request to create ElasticSearch Domain asynchronously
echo "Submitting the request to create ElasticSearch Domain ${ES_DOMAIN_NAME} asynchronously"
/home/hadoop/aws-resources/scripts/elastic_search/create_es_domain.ksh $ES_DOMAIN_NAME $ACCOUNT_ID $REGION &

# The ES Domain creation takes about 10 minutes. Hence sleeping for 10 mins before starting the project
echo "The ES Domain creation takes about 10 minutes. Hence sleeping for 10 mins before starting the pipeline."
sleep 600

#
copy_contents_2_s3_bucket

# Creating lambda role for S3.
create_lambda_role

attach_execution_roles_2_lambda_role

create_lambda_function ${MOVIE_GENRE_FUNC} ${DDB_GENRE_TABLE_NAME}

create_lambda_function ${OCCUP_MOVIE_GENRE_FUNC} ${DDB_OCCP_GENRE_TABLE_NAME}

attach_lamdba_func_2_s3 "arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${OCCUP_MOVIE_GENRE_FUNC}" \
"output\\/movie_count_by_occupation_and_genres\\/output" \
${OCCUP_MOVIE_GENRE_FUNC} \
"arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${MOVIE_GENRE_FUNC}" \
"output\\/movie_count_by_genres\\/output" \
${MOVIE_GENRE_FUNC}

create_ddb_table_1 ${DDB_GENRE_TABLE_NAME}

create_ddb_table_2 ${DDB_OCCP_GENRE_TABLE_NAME}

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

# Invoking the lambda for ddb stream creation
/home/hadoop/aws-resources/scripts/aws_dynamodb/streams/create_ddb_stream_lambda.sh -d $ES_DOMAIN_NAME -n es_lambda_function -g ${DDB_OCCP_GENRE_TABLE_NAME}

##**************************************
