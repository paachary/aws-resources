#!/bin/ksh

echo "Start...creating an EC2 instance in the public subnet"

response=`aws ec2 run-instances --image-id ami-7c87d913 --count 1 --instance-type t2.micro --key-name EC2SouthKP --security-group-ids ${security_grp_id} --subnet-id ${publicsubnetid}`

ec2Instanceid=`echo ${response}| jq '.Instances[0].InstanceId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${ec2Instanceid}" \
      --tags "Key"="Name","Value"="Web App Server" \
        "Key"="Type","Value"="ShellScript"

echo "Done...creating an EC2 instance in the public subnet - ${ec2Instanceid}"

echo "Start...creating a NAT instance in the public subnet"

response=`aws ec2 run-instances --image-id ami-0b3f4aad2015b0e15 --count 1 --instance-type t2.micro --key-name EC2SouthKP --security-group-ids ${security_grp_id} --subnet-id ${publicsubnetid}`

NATinstanceId=`echo ${response}| jq '.Instances[0].InstanceId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${NATinstanceId}" \
      --tags "Key"="Name","Value"="NAT Instance" \
        "Key"="Type","Value"="ShellScript"

echo "Done...creating an NAT instance in the public subnet - ${NATinstanceId}"

echo "Waiting for instances to become available..."

sleep 60

echo "Instances are now available.."

aws ec2 modify-instance-attribute \
        --instance-id ${NATinstanceId} \
        --source-dest-check "{\"Value\": false}" 

export NATinstanceId
export ec2Instanceid 
