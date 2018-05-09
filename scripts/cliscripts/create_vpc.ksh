#!/bin/ksh

export vpcName="Custom VPC"
export routeTableName="$vpcName RouteTable"
export igwName="$vpcName IGW"

echo "Creating custom VPC"

echo "Start...Creating a custom VPC"

response=`aws ec2 create-vpc --cli-input-json file://vpc_input.json`

vpcid=`echo $response | jq '.Vpc.VpcId' | tr -d '"'`

aws ec2 create-tags \
              --resources "${vpcid}" \
                    --tags "Key"="Name","Value"="${vpcName}" \
                            "Key"="Type","Value"="ShellScript"

aws ec2 modify-vpc-attribute --vpc-id ${vpcid} \
                --enable-dns-hostnames "{\"Value\":true}"

aws ec2 modify-vpc-attribute --vpc-id ${vpcid} \
                --enable-dns-support "{\"Value\":true}"

echo "Done...Creating a custom VPC -${vpcid} "

export vpcid
