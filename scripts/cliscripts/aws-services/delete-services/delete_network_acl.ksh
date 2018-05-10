#!/bin/ksh

echo "Start...Deleting Network ACLs"

response=`aws ec2 describe-network-acls --filters Name=tag:Type,Values=ShellScript | jq '.NetworkAcls[].NetworkAclId' | tr -d '"'| awk '{cmd="aws ec2 delete-network-acl --network-acl-id " $1; system(cmd)}'`

echo "Done...Deleting Network ACLs"
