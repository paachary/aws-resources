#!/bin/ksh

aws dynamodb delete-table \
    --table-name ProductCatalog
