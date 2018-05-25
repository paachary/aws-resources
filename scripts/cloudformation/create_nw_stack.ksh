#!/bin/bash

## Script for fetching the public ip address and updating the parameter files.
myipaddress=`curl --no-buffer https://www.iplocation.net/find-ip-address | grep 'IP Address is'| cut -f3 -d">"| cut -f1 -d"<"`

sed -i -e 's/"SSHLocation".*/"SSHLocation","ParameterValue": "'"${myipaddress}"'\/32"/' parameterfile/cfproperties*.json

aws cloudformation \
        create-stack \
        --stack-name NetworkStack \
        --template-body file://./templates/network/subnets_vpc_creation_template.json \
        --parameters file://./parameterfile/cfpropnetwork.json \
        --capabilities CAPABILITY_NAMED_IAM

