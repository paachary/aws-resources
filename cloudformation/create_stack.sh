#!/bin/bash

aws cloudformation \
        create-stack \
        --stack-name prax-stack-1 \
        --template-body file:///home/prashant/AWS_RESOURCES/cloudformation/vpc-ec2-for-lambda-exec-template.json \
        --parameters file:///home/prashant/AWS_RESOURCES/cloudformation/cfproperties.json

