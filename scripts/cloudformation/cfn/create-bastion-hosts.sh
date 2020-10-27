#!/bin/sh

# Before executing this script, please ensure you have created a keypair which will be used to access the ec2 hosts
# Default value of the keypair is a4lkeypair. If you want to create a keypair with another name, then please add the parameter component to the script below

aws cloudformation create-stack --stack-name a4l-bastion-hosts-rt-stack --template-body file://./bastion-hosts-route-tables-template.yaml
