#!/bin/ksh

if [ -z "$1" ]
then
    echo "Please supply VPC-ID value to the script"
    exit 1
fi

vpcid=$1

echo "Start...Deleting Internet Gateways"

response=`aws ec2 describe-internet-gateways  --filters Name=tag:Type,Values=ShellScript | jq '.InternetGateways[].InternetGatewayId'| tr -d '"'| awk -v env_var=$vpcid '{cmd="aws ec2 detach-internet-gateway --vpc-id "env_var" --internet-gateway-id "$1; system(cmd) ; cmd="aws ec2 delete-internet-gateway --internet-gateway-id " $1; system(cmd)}'`

echo "Done...Deleting Internet Gateways"
