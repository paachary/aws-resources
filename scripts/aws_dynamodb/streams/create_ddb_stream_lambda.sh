#!/bin/ksh

## Script for invoking the create data pipeline aws cli command based on the parameters / arguments 
## passed to the script
## Author : Prashant Acharya
## Usage:
## create-update-stack [options]
## options:
## -d --es-domain-name         :elasticsearch domain name [Required] [The name must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9, and - (hyphen).]
## -n --function-name          :lambda function name which will be attached to dynamodb stream. [Optional] [Default=es_lambda_function]
## -g --ddb-table-name         :dynamodb table name on which stream has been enabled [Optional] [Default=occupation_movies_genres]
## -h --help

##***
## Usage

usage()
{
    echo "usage: create-update-stack [options]
 options:
-d --es-domain-name         :elasticsearch domain name [Required] [The name must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9, and - (hyphen).]
-n --function-name          :lambda function name which will be attached to dynamodb stream. [Optional] [Default=es_lambda_function]
-g --ddb-table-name         :dynamodb table name on which stream has been enabled [Optional] [Default=occupation_movies_genres]
-h --help
    "
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --es-domain-name )        shift
                                       ES_DOMAIN_NAME=$1
                                       ;;           
        -n | --function-name )         shift
                                       LAMDBA_FUNCTION=$1
                                       ;;      
        -g | --ddb-table-name )        shift
                                       DDB_TABLE_NAME=$1
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

if [ -z ${LAMDBA_FUNCTION} ]
then
    LAMDBA_FUNCTION="es_lambda_function"
fi

if [ -z ${DDB_TABLE_NAME} ]
then
    DDB_TABLE_NAME="occupation_movies_genres"
fi

echo ${LAMDBA_FUNCTION} 
echo ${DDB_TABLE_NAME} 

ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | tr -d '"'`
echo $ACCOUNT_ID

REGION=`aws configure list | grep region| awk '{print $2}'`
echo $REGION

create_lambda_role()
{
    POLICY_FILE=$HOME/trust-relationship.json
    
    rm -f $POLICY_FILE
    
    cp /home/hadoop/aws-resources/scripts/aws_dynamodb/streams/trust-relationship.json $POLICY_FILE
    
    response=`aws iam create-role --role-name ddbstreamlambarole \
    --path "/service-role/" \
    --assume-role-policy-document file://$POLICY_FILE`
    
    roleArn=`echo $response | jq '.Role.Arn' | tr -d '"'`
    
    echo $roleArn
    
    sleep 30

}

assign_role_policy()
{
    POLICY_FILE=$HOME/role_policy.json
    
    rm -f $POLICY_FILE
    
    cp /home/hadoop/aws-resources/scripts/aws_dynamodb/streams/role-policy.json $POLICY_FILE
    
    streamArn=`aws dynamodb describe-table --table-name ${DDB_TABLE_NAME} | jq '.Table.LatestStreamArn' | tr -d '"'`
    
    streamTS=`echo $streamArn | cut -d"/" -f 4`
    echo $streamTS
    
    ddbStreamArn="arn:aws:dynamodb:$REGION:$ACCOUNT_ID:table\\/$DDB_TABLE_NAME\\/stream\\/$streamTS\\/*"
    echo $ddbStreamArn
    
    lambdaArn="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${LAMDBA_FUNCTION}"
    
    logsArn="arn:aws:logs:region:$ACCOUNT_ID:*"
    
    sed -i -e 's/LOGS_ARN/"'"${logsArn}"'"/' $POLICY_FILE   
    
    sed -i -e 's/LAMBDA_FUNCTION_ARN/"'"${lambdaArn}"'"/' $POLICY_FILE    
    
    sed -i -e 's/STREAM_ARN/"'"${ddbStreamArn}"'"/' $POLICY_FILE
    
    response=`aws iam put-role-policy --role-name ddbstreamlambarole \
    --policy-name ddbstreamlambarolepolicy \
    --policy-document file://$POLICY_FILE`
    
}

attach_execution_roles_2_lambda_role()
{
    echo "Attaching the BasicExecution for Lambda role"
    
    # Attaching the BasicExecution for Lambda
    response=`aws iam attach-role-policy --role-name ddbstreamlambarole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`

    echo $response

     echo "Attaching the Full access on S3 for Lambda role"
        
    # Attaching the AmazonS3FullAccess for Lambda
    response=`aws iam attach-role-policy --role-name ddbstreamlambarole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess`

    echo $response
    
    echo "Attaching the Full access on Dynamodb for Lambda role"
        
    # Attaching the AmazonDynamoDBFullAccess for Lambda
    response=`aws iam attach-role-policy --role-name ddbstreamlambarole --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess`

    echo $response
}


create_es_domain()
{
    IAM_ROOT_ARN="arn:aws:iam::${ACCOUNT_ID}:root"
    ES_DOMAIN_ARN="arn:aws:es:${REGION}:${ACCOUNT_ID}:domain/${ES_DOMAIN_NAME}/*"

 
    response=`aws es create-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} \
    --elasticsearch-version 7.4 \
    --elasticsearch-cluster-config InstanceType=t2.small.elasticsearch,InstanceCount=1 \
    --ebs-options EBSEnabled=true,VolumeType=gp2,VolumeSize=10 \
    --access-policies \
    '{"Version": "2012-10-17", "Statement":[ { "Effect": "Allow", "Principal": {"AWS": "'"${IAM_ROOT_ARN}"'" },"Action":"es:*","Resource": "'"${ES_DOMAIN_ARN}"'" } ] }'`
    
    echo "Please wait while domain is being created and loaded. This may take about 10 minutes."
    
    response=`aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME}`
    
    status=`echo $response | jq '.DomainStatus.Processing'`    

    while [ "$status" != false ]
    do
        sleep 60
        status=`aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} | jq '.DomainStatus.Processing' | tr -d '"'`
        if [ "$status" == true  ]
        then
            break
        fi
    done
    
    domainEndPoint=`aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} | jq '.DomainStatus.Endpoint' | tr -d '"'`
    echo $domainEndPoint
}

create_lambda_function()
{    
    ES_END_POINT=$1
    echo "ES Domain Name = $ES_END_POINT"
    
    echo "Lambda Function name - $LAMDBA_FUNCTION"
    
    roleArn="arn:aws:iam::${ACCOUNT_ID}:role/service-role/ddbstreamlambarole"
    
    # Zipping the python lamdba code.
    
    if [ -d "./install" ]
    then
        rm -fr ./install    
    fi
    
    mkdir install
    
    cd install
    
    cp /home/hadoop/aws-resources/scripts/elastic_search/es_lambda_function.py ${LAMDBA_FUNCTION}.py
    
    pip install elasticsearch requests_aws4auth -t .
    
    rm -f function.zip
    
    zip -r function.zip *

    # Creating the lamdba function
    response=`aws lambda create-function \
    --function-name ${LAMDBA_FUNCTION} \
    --zip-file fileb://function.zip \
    --handler ${LAMDBA_FUNCTION}.lambda_handler \
    --runtime python3.7 \
    --environment Variables={ES_URL="'"${ES_END_POINT}"'"} \
    --role $roleArn`

    lamdaArn=`echo $response | jq '.FunctionArn' | tr -d '"'`
    echo $lamdaArn
    
    streamArn=`aws dynamodb describe-table --table-name ${DDB_TABLE_NAME} | jq '.Table.LatestStreamArn' | tr -d '"'`
    
    response=`aws lambda create-event-source-mapping \
    --region us-east-1 \
    --function-name ${LAMDBA_FUNCTION} \
    --event-source ${streamArn}  \
    --batch-size 1 \
    --starting-position TRIM_HORIZON`
    
    cd -
    
    rm -fr ./install
}

create_lambda_role

assign_role_policy

attach_execution_roles_2_lambda_role

create_es_domain

esEndPoint=(create_es_domain)

create_lambda_function $esEndPoint
