#!/bin/sh

aws cloudformation create-stack --stack-name a4l-app-server-private-subnet-stack --template-body file://./appserver-host-private-subnet-template.yaml


