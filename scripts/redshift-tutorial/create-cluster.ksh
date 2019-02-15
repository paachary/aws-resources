#!/bin/ksh

aws redshift create-cluster --cli-input-json file://cluster-creation-json.json
