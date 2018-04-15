#!/bin/ksh

echo "Starting the cleanup script"

## Getting the VPC id which is linked to all the related resources

echo "Start... Getting the VPC ID for Type = ShellScript tag"

vpcid=`aws ec2 describe-vpcs --filters Name=tag:Type,Values=ShellScript | jq '.Vpcs[0].VpcId'| tr -d '"'`

echo "Done...Getting the VPC ID for Type = ShellScript tag:: VPCID = ${vpcid}"

## Deleting the EC2 instances
./delete_instance.ksh

## Deleting subnets
./delete_subnet.ksh

## Deleting the Security Groups
./delete_security_group.ksh

## Deleting the Route Tables
./delete_route_table.ksh

## Deleting network acls
./delete_network_acl.ksh

## Deleting internet gateway
./delete_internet_gateway.ksh ${vpcid}

## Deleting the VPC
./delete_vpc.ksh ${vpcid}

## Complete
echo "Ending the cleanup script"
