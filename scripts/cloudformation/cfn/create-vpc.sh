#!/bin/sh

aws cloudformation create-stack --stack-name a4l-stack --template-body file://./vpc-cfn-template.yaml

