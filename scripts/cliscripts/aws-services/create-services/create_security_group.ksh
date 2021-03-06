#!/bin/ksh

## Script for fetching the public ip address and updating the parameter files.
myipaddress=`curl --no-buffer https://www.iplocation.net/find-ip-address | grep 'IP Address is'| cut -f3 -d">"| cut -f1 -d"<"`

echo "Start...creating security group"

response=`aws ec2 create-security-group \
        --group-name "WebDMZ" \
        --description "Web DMZ Security Group" \
        --vpc-id ${vpcid}`

security_grp_id=`echo ${response}| jq '.GroupId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${security_grp_id}" \
      --tags "Key"="Name","Value"="WebDMZ" \
        "Key"="Type","Value"="ShellScript"

echo "Done...creating security group - ${security_grp_id}"

echo "Start...associating rules to security group"

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 22 --cidr "${myipaddress}/32`

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 80 --cidr 0.0.0.0/0`

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 443 --cidr 0.0.0.0/0`

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 22 --source-group ${security_grp_id}`

export security_grp_id
