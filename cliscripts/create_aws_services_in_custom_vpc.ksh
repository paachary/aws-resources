#!/bin/ksh

echo "Creating AWS services within a custom VPC"

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

## Create EC2 Instances
. ./create_ec2_instances.ksh

## Create gateways to route table associations
. ./create_gateways_to_route_tables.ksh


echo "Done with creation of AWS services within a custom VPC: ${vpcid}"
