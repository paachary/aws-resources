#!/bin/bash

if [ -z $1 ]
then
    echo "Please specify stack name"
    exit 1
fi

if [ -z $2 ]
then
    echo "Please specify the template name in json format"
    exit 1
fi


aws cloudformation \
        create-stack \
        --stack-name $1 \
        --template-body file:///home/prashant/AWS_RESOURCES/cloudformation/$2 \
        --parameters file:///home/prashant/AWS_RESOURCES/cloudformation/cfproperties.json \
        --capabilities CAPABILITY_IAM

