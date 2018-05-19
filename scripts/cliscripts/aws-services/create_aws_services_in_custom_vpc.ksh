#!/bin/ksh
#################################################################################################################
#
#   Author : Prashant Acharya
#   Date   : April 15, 2018
#   Purpose: This script sets up the required services to configure Web application along with databases
#   
#          VPC           - Custom VPC
#          Internet Gateway
#          Subnets       - 4 Private Subnets ( 2 each in 2 Availability Zones
#                          1 Public Subnet to host one Bastion Server and one NAT Instance
#          NACL          - The inbound and outbound rules allow basic minimum protocols on the required ports
#                          HTTP / HTTPS / SSH / iCMP
#                          All the subnets have been setup on the NACL
#          Security Group- Security Group has been configured to allow the above basic rules
#          Route Tables  - Two route tables are created:
#                           1. To route traffic from / to private subnets. The NAT instance is added to this route table
#                           2. To route traffic from / to public subnet. The Internet Gateway is added to this route table
#          EC2 Instances - Two EC2 instances are created by this script
#                          1. NAT instance on the public subnet
#                          2. Bastion Server to allow connection to EC2 instances on private subnets
#
#          This script can be used to setup the above infrastructure for development without having to 
#          create these services individually.
#
#          If more services need to be added, please leave a comment or feel free to upload your version of the code
#          and share for review.
#          
##################################################################################################################

if [ -z "$1" ]
then
    ec2="true"
else
    ec2="false"

fi

cd create-services

echo "Creating AWS services within a custom VPC"

## Set the environment variables
. ./set_env.ksh

## Create Custom VPC
. ./create_vpc.ksh

## Create Internet Gateway
. ./create_internet_gateway.ksh

## Create Subnets
. ./create_subnets.ksh

## Create Route Tables
. ./create_route_tables.ksh

## Create Network ACLs
. ./create_network_acl.ksh

## Create subnet to NACL association
. ./create_subnet_nacl_assoc.ksh

## Create Security Groups
. ./create_security_group.ksh

## Create NAT instance
. ./create_nat_instance.ksh

## Create EC2 Instances
. ./create_ec2_instances.ksh

## Create gateways to route table associations
. ./create_gateways_to_route_tables.ksh


if [[ ${ec2} == "false" ]]
then
    ## Creating instance profile associated to the autoscaling launch configuration
    . ./create_instance_profile.ksh

    ## Create autoscaling group
    . ./create_target_group.ksh
    . ./create_app_load_balancer.ksh
    . ./create_auto_scaling_group.ksh
fi

echo "Waiting for instances to become available..."                                                                                       
sleep 90

echo "Instances are now available.."

echo "Done with creation of AWS services within a custom VPC: ${vpcid}"
