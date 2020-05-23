#!/bin/ksh

## Script for invoking the create data pipeline aws cli command based on the parameters / arguments 
## passed to the script
## Author : Prashant Acharya
## Usage:
## create-update-stack [options]
## options:
##  -b --bucket-name : s3 bucket name which contains the scripts and input files. [required]
##  -k --key-name    : emr Key Name needed for connecting to the emr cluster instanes [required]
##  -h --help

##***
## Usage

usage()
{
    echo "usage: create-update-stack [options]
                options:
                    -b --bucket-name : s3 bucket name which contains the scripts and input files. [required]
                    -k --key-name    : emr Key Name needed for connecting to the emr cluster instanes [required]
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
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z ${BUCKET_NAME} ] | [ -z ${EMRKEYPAIR} ]
then
    usage
    exit 1
fi

PROPERTIES_FILE="$HOME/DataPipeLineProperties.json"
BUCKET="s3://${BUCKET_NAME}"

echo $BUCKET
echo $EMRKEYPAIR
echo $PROPERTIES_FILE

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

##***********************

## Invoking the user defined functions for setting up the environment

create_DataPipeLinePropertiesFile_from_Template

create_ec2_keyPair

fetch_current_aws_region

fetch_1st_public_subnet_id

update_s3_bucket_name

copy_contents_2_s3_bucket


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
