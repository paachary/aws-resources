#!/bin/ksh

alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"

ENV_FILE="setenv.ksh"

if [[ -e "$ENV_FILE" ]]
then
    . ${ENV_FILE}
else
    export EMRKEYPAIR="emrKeyPair" 
fi

response=`aws ec2 create-key-pair --key-name ${EMRKEYPAIR}`
echo $response | jq '.KeyMaterial' | tr -d '"' > $HOME/${EMRKEYPAIR}.pem

ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | tr -d '"'`
echo $ACCOUNT_ID

REGION=`aws configure list | grep region| awk '{print $2}'`
echo $REGION

response=`aws emr create-default-roles`

response=`aws emr create-cluster \
--name "Spark-Cluster" \
--release-label emr-5.30.0 \
--ec2-attributes '{"KeyName":"'"${EMRKEYPAIR}"'","InstanceProfile":"EMR_EC2_DefaultRole"}' \
--service-role EMR_DefaultRole \
--enable-debugging \
--log-uri "s3n://aws-logs-${ACCOUNT_ID}-${REGION}/elasticmapreduce/" \
--applications Name=Spark \
               Name=Zeppelin \
--instance-type m4.large \
--instance-count 3 \
--region ${REGION} \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION`

cluster_id=`echo $response | jq '.ClusterId' | tr -d '"'`

cluster_state=`aws emr describe-cluster --cluster-id ${cluster_id} | jq '.Cluster.Status.State'`

echo $cluster_state
