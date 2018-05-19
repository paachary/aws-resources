#!/bin/ksh

echo "Start...Creating a Target Group"

response=`aws elbv2 create-target-group --name targetGroup --protocol HTTP --port 80 --target-type instance --vpc-id ${vpcid}`

targetGroupArn=`echo $response | jq '.TargetGroups[].TargetGroupArn' | tr -d '"'`

echo "Done...Creating a Target Group -${targetGroupArn} " 

export targetGroupArn
