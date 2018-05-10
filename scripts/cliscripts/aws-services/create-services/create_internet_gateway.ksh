#!/bin/ksh

echo "Start...Creating a custom internet gateway"

igw=`aws ec2 create-internet-gateway`

igwid=`echo $igw| awk -F'["-,:]' '/,/{gsub(/ /, "", $0);print $12 }'`

aws ec2 create-tags \
   --resources "$igwid" \
   --tags "Key"="Name","Value"="$igwName" \
          "Key"="Type","Value"="ShellScript"

aws ec2 attach-internet-gateway --vpc-id ${vpcid} --internet-gateway-id ${igwid}

echo "Done...Creating a custom internet gateway - ${igwid} and attaching it to VPC : ${vpcid}"

export igwid
