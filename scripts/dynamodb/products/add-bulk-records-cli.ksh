#!/bin/ksh

aws dynamodb batch-write-item \
    --request-items file://productcatalog-items.json
