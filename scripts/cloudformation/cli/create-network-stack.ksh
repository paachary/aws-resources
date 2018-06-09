#!/bin/bash

## Creating network stack

create-update-stack \
        -s NetworkStack \
        -t /home/prashant/aws-resources/scripts/cloudformation/templates/network/subnets_vpc_creation_template.json \
        -p /home/prashant/aws-resources/scripts/cloudformation/parameterfile/cfpropnetwork.json

