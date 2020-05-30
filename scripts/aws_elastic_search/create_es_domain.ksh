#!/bin/ksh

create_es_domain()
{
    DOMAIN_NAME=$1
    ACCOUNT_ID=$2
    REGION=$3

    IAM_ROOT_ARN="arn:aws:iam::${ACCOUNT_ID}:root"
    ES_DOMAIN_ARN="arn:aws:es:${REGION}:${ACCOUNT_ID}:domain/${DOMAIN_NAME}/*"

 
    response=`aws es create-elasticsearch-domain --domain-name ${DOMAIN_NAME} \
    --elasticsearch-version 7.4 \
    --elasticsearch-cluster-config InstanceType=t2.small.elasticsearch,InstanceCount=1 \
    --ebs-options EBSEnabled=true,VolumeType=gp2,VolumeSize=10 \
    --access-policies \
    '{"Version": "2012-10-17", "Statement":[ { "Effect": "Allow", "Principal": {"AWS": "*" },"Action":"es:*" } ] }'` 

}
DOMAIN_NAME=$1
ACCOUNT_ID=$2
REGION=$3

if [ -z ${DOMAIN_NAME} ]
then
    echo "Domain Name has not been selected. Please select domain name and re-submit the request."
    exit 1
fi

if [ -z ${ACCOUNT_ID} ]
then
    echo "Not able to determine AWS Account id. Please resubmit with accurate values."
    exit 1
fi

if [ -z ${REGION} ]
then
    echo "Not able to determine AWS Region. Please resubmit with accurate values."
    exit 1
fi
# USAGE : create_es_domain < Domain Name> <AWS Account ID> <AWS Region>
create_es_domain ${DOMAIN_NAME} ${ACCOUNT_ID} ${REGION}
