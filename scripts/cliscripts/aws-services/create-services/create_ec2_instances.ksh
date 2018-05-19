#!/bin/ksh

echo "Start...creating an EC2 instance in the public subnet"

response=`aws ec2 run-instances --image-id ${AMIID} --count 1 --instance-type t2.micro --key-name ${EC2KEYPAIR} --security-group-ids ${security_grp_id} --subnet-id ${publicsubnetid}`

ec2Instanceid=`echo ${response}| jq '.Instances[0].InstanceId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${ec2Instanceid}" \
      --tags "Key"="Name","Value"="Web App Server" \
        "Key"="Type","Value"="ShellScript"

echo "Done...creating an EC2 instance in the public subnet - ${ec2Instanceid}"

export ec2Instanceid 
