#!/bin/ksh

## Retrieve the instance profile

response=`aws iam get-instance-profile --instance-profile-name CloudWatch-EC2-Instance-Profile`

instanceProfileArn=`echo $response | jq '.InstanceProfile.Arn' | tr -d '"'`

## Create autoscaling launch configuration with one specific AMI.

echo "Start...Creating autoscaling launch configuration"

response=`aws autoscaling create-launch-configuration \
--launch-configuration-name as-launch-config \
--key-name ${EC2KEYPAIR} --security-groups ${security_grp_id} \
--image-id ${AMIID} \
--instance-type t2.micro \
--user-data file://./policies/instance_bootstrap.ksh \
--iam-instance-profile  "${instanceProfileArn}"`

echo "Done...Creating autoscaling launch configuration - as-launch-config"

## Create autoscaling group based on the above created launch configuration

echo "Start...Creating autoscaling group"

response=`aws autoscaling create-auto-scaling-group \
--auto-scaling-group-name as-group \
--launch-configuration-name as-launch-config \
--min-size 2 \
--desired-capacity 2 \
--max-size 2 \
--target-group-arns ${targetGroupArn} \
--health-check-type ELB \
--health-check-grace-period 120 \
--vpc-zone-identifier ${subnetids[1]},${subnetids[2]},${subnetids[3]},${subnetids[4]}`

echo "Start...Creating autoscaling group - as-group"

