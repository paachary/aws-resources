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

# get the subnet id
SUBNETID=`aws ec2 describe-subnets | jq '.Subnets[0] | select(.State == "available" and .MapPublicIpOnLaunch == true) | .SubnetId'| tr -d '"'`
echo "subnetid = ${SUBNETID}"

response=`aws emr create-cluster \
    --applications Name=Spark Name=Hadoop Name=Hive Name=Zeppelin\
    --ec2-attributes '{"KeyName":"'"${EMRKEYPAIR}"'",\
                       "InstanceProfile":"EMR_EC2_DefaultRole",\
                       "SubnetId":"'"${SUBNETID}"'"}' \
    --service-role EMR_DefaultRole \
    --release-label emr-5.30.0 \
    --name 'emcliCluster' \
    --instance-groups '[{"InstanceCount":1,\
                         "EbsConfiguration":\
                            {"EbsBlockDeviceConfigs":\
                              [{"VolumeSpecification":\
                                 {"SizeInGB":32,"VolumeType":"gp2"},
                                 "VolumesPerInstance":1}]},\
                              "InstanceGroupType":"MASTER",\
                              "InstanceType":"m4.large",\
                              "Name":"Master Instance Group"},\
                        {"InstanceCount":2,"EbsConfiguration":\
                           {"EbsBlockDeviceConfigs":\
                              [{"VolumeSpecification":\
                                 {"SizeInGB":32,"VolumeType":"gp2"},\
                              "VolumesPerInstance":1}]},\
                              "InstanceGroupType":"CORE",\
                              "InstanceType":"m4.large",\
                              "Name":"Core Instance Group"}]' \
    --configurations '[{"Classification":"spark","Properties":{}}]' \
    --scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
    --region ${REGION}` 

cluster_id=`echo $response | jq '.ClusterId' | tr -d '"'`


cluster_state=`aws emr describe-cluster --cluster-id ${cluster_id} | jq '.Cluster.Status.State'`

echo $cluster_state
