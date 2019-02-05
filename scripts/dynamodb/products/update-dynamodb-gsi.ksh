#!/bin/ksh

aws dynamodb update-table --table-name ProductCatalog --cli-input-json file://Price-ProductType-Index.json
