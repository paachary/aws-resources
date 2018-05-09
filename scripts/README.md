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
