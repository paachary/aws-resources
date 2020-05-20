#!/bin/ksh

alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"

ENV_FILE="$HOME/setenv.ksh"

if [[ -e "$ENV_FILE" ]]
then
    . ${ENV_FILE}
else
    export EC2KEYPAIR="ec2keypair" 
fi

response=`aws ec2 create-key-pair --key-name ${EC2KEYPAIR}`
echo $response | jq '.KeyMaterial' | tr -d '"' > $HOME/ec2keypair.pem

ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | tr -d '"'`
echo $ACCOUNT_ID

REGION=`aws configure list | grep region| awk '{print $2}'`
echo $REGION

response=`aws emr create-default-roles`

response=`aws emr create-cluster \
--name "Spark-Cluster" \
--release-label emr-5.30.0 \
--ec2-attributes '{"KeyName":"ec2keypair","InstanceProfile":"EMR_EC2_DefaultRole"}' \
--service-role EMR_DefaultRole \
--enable-debugging \
--log-uri "s3n://aws-logs-${ACCOUNT_ID}-${REGION}/elasticmapreduce/" \
--applications Name=Oozie \
               Name=Spark \
               Name=Phoenix \
               Name=HBase \
               Name=Hive \
               Name=Oozie \
               Name=Zeppelin \
--instance-type m4.large \
--instance-count 3 \
--region ${REGION} \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION`

cluster_id=`echo $response | jq '.ClusterId' | tr -d '"'`

cluster_state=`aws emr describe-cluster --cluster-id ${cluster_id} | jq '.Cluster.Status.State'`

while [ ${cluster_state} != "Waiting" ]
do
    sleep 30
done

echo "Cluster is successfully provisioned"

