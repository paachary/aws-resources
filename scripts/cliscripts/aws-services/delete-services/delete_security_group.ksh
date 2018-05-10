#!/bin/ksh

echo "Start...Deleting Security Groups"

response=`aws ec2 describe-security-groups --filters Name=tag:Type,Values=ShellScript| jq '.SecurityGroups[].GroupId' | tr -d '"' | awk '{cmd="aws ec2 delete-security-group --group-id "$1; system(cmd)}'`

echo "Done...Deleting Security Groups"
