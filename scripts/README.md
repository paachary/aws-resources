# aws-resources


## The repository contains scripts and templates for various AWS services.

### Cloudformation:
Inside the templates directory, there are working templates for creating AWS components and services in a non-default VPC. 
####  1. AutoScaling_Webapp_Redis_VPC.json :
  This template can be used for creating a sample Flask (Python-3.6) based web application with Redis as the backend database.
  This application runs in a non-default VPC in a multi-AZ, load-balanced and Autoscaled platform. 
  The Redis server runs on an independent host in a private subnet.  The Web servers run multi-AZs on private subnets. 
  The Redis server can be accessible only from the web servers. The Web servers are hosted behind an external facing load balancer.


####  2. BastionHost_privateec2_nondefault_VPC.json:
  This template can be used for creating 4 EC2 instances in a non-default VPC. 
  The template creates one NAT instance, one bastion host (both hosted in a public subnet) and two web servers 
  hosted in a private subnet fronted by an elastic load balancer in public subnets. 


####  3. BastionHost_publicec2_nondefault_VPC.json
  This template  can be used for creating 4 EC2 instances in a non-default VPC. 
  The template creates one NAT instance, one bastion host (both hosted in a public subnet) and two web servers hosted in public subnets.
 

### DynamoDB:

The directory contains python scripts using SDK with boto3 to setup and tear-down a set of dynamodb tables.


### CLI Scripts

This directory contains aws cli commands embedded within shell scripts. The scripts are used to create a 
non-default VPC with multiple private and public subnets, including two EC2 instances along with a NAT instance.

#### Script for creating services: create_aws_services_in_custom_vpc.ksh

#### Script for cleaning up the services: cleanup.ksh

## Following components / services are created:

          VPC           - Custom VPC
          Internet Gateway
          Subnets       - 4 Private Subnets ( 2 each in 2 Availability Zones
                          1 Public Subnet to host one Bastion Server and one NAT Instance
          NACL          - The inbound and outbound rules allow basic minimum protocols on the required ports
                          HTTP / HTTPS / SSH / iCMP
                          All the subnets have been setup on the NACL
          Security Group- Security Group has been configured to allow the above basic rules
          Route Tables  - Two route tables are created:
                           1. To route traffic from / to private subnets. The NAT instance is added to this route table
                           2. To route traffic from / to public subnet. The Internet Gateway is added to this route table
          EC2 Instances - Two EC2 instances are created by this script
                          1. NAT instance on the public subnet
                          2. Bastion Server to allow connection to EC2 instances on private subnets


