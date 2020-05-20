#!/bin/ksh

ENV_FILE="setenv.ksh"

if [[ -e "$ENV_FILE" ]]
then
    . ${ENV_FILE}
else
    export EMRKEYPAIR="emrKeyPair" 
fi

#Deleting the emr cluster
clusterid=`aws emr list-clusters --active  | jq '.Clusters[0].Id' | tr -d '"'`

# TBD code for multiple clusters"
echo "Deleting the emr cluster"
response=`aws emr terminate-clusters --cluster-ids ${clusterid}`
echo $response

response=`aws ec2 describe-key-pairs --key-name ${EMRKEYPAIR}`
if [ $? -eq 0 ]
then
    #Deleting the custom key pair created for emr cluster
    echo "Deleting custom key pair created for emr cluster"
    response=`aws ec2 delete-key-pair --key-name ${EMRKEYPAIR}`
fi

#Remove EMR_EC2_DefaultRole from the instance profile
echo "Remove EMR_EC2_DefaultRole from the instance profile"
response=`aws iam remove-role-from-instance-profile --instance-profile-name EMR_EC2_DefaultRole --role-name EMR_EC2_DefaultRole`
echo $response

#Delete the instance profile
echo "Delete the instance profile"
response=`aws iam delete-instance-profile --instance-profile-name EMR_EC2_DefaultRole`
echo $response

#Delete the IAM policy associated with EMR_EC2_DefaultRole
echo "Delete the IAM policy associated with EMR_EC2_DefaultRole"
response=`aws iam detach-role-policy --role-name EMR_EC2_DefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role`
echo $response

#Delete EMR_EC2_DefaultRole
echo "Delete EMR_EC2_DefaultRole"
response=`aws iam delete-role --role-name EMR_EC2_DefaultRole`
echo $response

#Delete the IAM policy associated with EMR_DefaultRole
echo "Delete the IAM policy associated with EMR_DefaultRole"
response=`aws iam detach-role-policy --role-name EMR_DefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole`
echo $response

#Delete EMR_DefaultRole
echo "Delete EMR_DefaultRole"
response=`aws iam delete-role --role-name EMR_DefaultRole`
echo $response
