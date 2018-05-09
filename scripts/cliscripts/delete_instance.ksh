#!/bin/ksh

echo "Start...Deleting EC2 Instances"

response=`aws ec2 describe-instances  --filters Name=tag:Type,Values=ShellScript | jq '.Reservations[].Instances[].InstanceId' | tr -d '"'| awk '{cmd="aws ec2 terminate-instances --instance-ids "$1; system(cmd)}'`

sleep 120

echo "Done...Deleting EC2 Instances"
