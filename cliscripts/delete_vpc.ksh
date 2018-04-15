#!/bin/ksh

if [ -z "$1" ]
then
    echo "Please pass the VPC-ID value as a parameter to this script"
    exit 1
fi

vpcid=$1

echo "Start.. Deleting the VPC: ${vpcid}"

response=`aws ec2 delete-vpc --vpc-id ${vpcid}`

echo "Done.. Deleting the VPC: ${vpcid}"
