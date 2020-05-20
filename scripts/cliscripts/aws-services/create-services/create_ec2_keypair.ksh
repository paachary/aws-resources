#!/bin/ksh

ENV_FILE="$HOME/setenv.ksh"

if [[ -e "$ENV_FILE" ]]
then
    . ${ENV_FILE}
else
    export EC2KEYPAIR="ec2keypair" 
fi

response=`aws ec2 create-key-pair --key-name ${EC2KEYPAIR}`
echo $response | jq '.KeyMaterial' | tr -d '"' > $HOME/ec2keypair.pem

aws emr create-cluster \
--name "Spark cluster" \
--release-label emr-5.30.0 \
--applications Name=Spark Name=Phoenix Name=HBase Name=Hive Name=Oozie
--ec2-attributes KeyName=${EC2KEYPAIR} \
--instance-type m5.xlarge \
--instance-count 3 \
--use-default-roles
