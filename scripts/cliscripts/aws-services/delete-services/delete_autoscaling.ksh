#!/bin/ksh

echo "Start...Terminate autoscaling instances"

response=`aws autoscaling describe-auto-scaling-instances | jq '.AutoScalingInstances[].InstanceId' | tr -d '"'`

echo $response

for instance in ${response[@]}
do
    echo "Processing instance id -"${instance}
    response1=`aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${instance} --should-decrement-desired-capacity`
done

echo "Done...Terminate autoscaling instances"


echo "Start...Modify autoscaling group"

response=`aws autoscaling update-auto-scaling-group \
        --auto-scaling-group-name as-group   \
        --min-size 0 \
        --max-size 0 \
        --desired-capacity 0 2> /dev/null`

echo "Done...Modify autoscaling group"

echo "Start...Deleting the autoscaling group"

response=`aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name as-group 2> /dev/null`

echo "Done...Deleting the autoscaling group"

echo "Start...Deleting the autoscaling launch configuration"

response=`aws autoscaling delete-launch-configuration \
        --launch-configuration-name as-launch-config 2> /dev/null`

echo "Done...Deleting the autoscaling launch configuration"

