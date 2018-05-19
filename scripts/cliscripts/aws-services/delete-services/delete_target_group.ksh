#!/bin/ksh

echo "Start...Deleting Target Groups"

response=`aws elbv2 describe-target-groups --name targetGroup 2> /dev/null`

if [[ $? == 0 ]]
then
    targetGroupArn=`echo $response | jq '.TargetGroups[].TargetGroupArn' | tr -d '"'`        
    response=`aws elbv2 delete-target-group --target-group-arn ${targetGroupArn}`
fi

echo "Done...Deleting Target Groups"

