#!/bin/bash

## Creating network stack

create-update-stack \
        -s NetworkStack \
        -t $HOME/aws-resources/scripts/cloudformation/templates/network/subnets_vpc_creation_template.json \
        -p $HOME/aws-resources/scripts/cloudformation/parameterfile/cfpropnetwork.json

