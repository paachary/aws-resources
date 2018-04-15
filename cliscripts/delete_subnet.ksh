#!/bin/ksh

echo "Start...Deleting Subnets"

response=`aws ec2 describe-subnets --filters Name=tag:Type,Values=ShellScript | jq '.Subnets[].SubnetId'| tr -d '"' | awk '{cmd="aws ec2 delete-subnet --subnet-id "$1; system(cmd)}'`

echo "Done...Deleting Subnets"
