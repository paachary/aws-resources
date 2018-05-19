#!/bin/ksh

echo "Start...creating a NAT instance in the public subnet"

response=`aws ec2 run-instances --image-id ${NATAMIID} --count 1 --instance-type t2.micro --key-name ${EC2KEYPAIR} --security-group-ids ${security_grp_id} --subnet-id ${publicsubnetid}`

NATinstanceId=`echo ${response}| jq '.Instances[0].InstanceId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${NATinstanceId}" \
      --tags "Key"="Name","Value"="NAT Instance" \
        "Key"="Type","Value"="ShellScript"

echo "Done...creating an NAT instance in the public subnet - ${NATinstanceId}"

aws ec2 modify-instance-attribute \
        --instance-id ${NATinstanceId} \
        --source-dest-check "{\"Value\": false}" 

export NATinstanceId
sleep 30

