#!/bin/ksh
aws dynamodb create-table \
    --table-name ProductCatalog \
    --attribute-definitions \
          AttributeName=Id,AttributeType=N \
    --key-schema  AttributeName=Id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=5



