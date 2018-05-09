#!/bin/ksh
#################################################################################################################
#
#   Author : Prashant Acharya
#   Date   : April 15, 2018
#   Purpose: This script cleans up the services created by create_aws_services_in_custom_vpc.ksh script
#            This script relies on the tag added "Type = ShellScript" added to the services while creating them
#   
#            Currently this script supports deletion of:
#              * VPC
#              * NACL
#              * Subnets
#              * EC2 instances
#              * Security Group
#              * Internet Gateway
#              * Route Tables
#
#            This script can be used to tear down the services created originally as mentioned above.
#            Further, if there are other instances of above mentioned services that were created to 
#            support web server / databases etc, they can be tagged with "Name = Type" and "Value = ShellScript".
#            This script will delete those services as well.
#            If more services need to be added for deletion, please leave a comment or feel free to upload your version of the code
#            and share for review.
#          
##################################################################################################################

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
