#!/bin/ksh

echo "Start...Deleting Route Tables"

response=`aws ec2 describe-route-tables --filters Name=tag:Type,Values=ShellScript | jq '.RouteTables[].RouteTableId' | tr -d '"'| awk '{cmd="aws ec2 delete-route-table --route-table-id "$1; system(cmd)}'`

echo "End...Deleting Route Tables"
