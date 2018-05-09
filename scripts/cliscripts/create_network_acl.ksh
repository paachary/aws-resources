#!/bin/ksh

echo "Start...Creating a network ACL"

network_acl_response=`aws ec2 create-network-acl --vpc-id $vpcid`
network_acl_id=`echo $network_acl_response | jq '.NetworkAcl.NetworkAclId' | tr -d '"'`
aws ec2 create-tags \
  --resources "${network_acl_id}" \
  --tags "Key"="Name","Value"="NetworkAcl-${vpcName}" \
         "Key"="Type","Value"="ShellScript"

echo "Done...Creating a network ACL - $network_acl_id"

echo "Start...Creating NACL entries"

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --ingress \
        --rule-number 100 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=80,To=80

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --ingress \
        --rule-number 200 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=443,To=443

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --ingress \
        --rule-number 300 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=22,To=22

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --ingress \
        --rule-number 400 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=1024,To=65535

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --ingress \
        --rule-number 500 \
        --protocol icmp \
        --icmp-type-code "Code"=-1,"Type"=-1 \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=53,To=53

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --egress \
        --rule-number 100 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=80,To=80

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --egress \
        --rule-number 200 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=443,To=443

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --egress \
        --rule-number 300 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=1024,To=65535

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --egress \
        --rule-number 400 \
        --protocol icmp \
        --icmp-type-code "Code"=-1,"Type"=-1 \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=53,To=53

aws ec2 create-network-acl-entry \
        --network-acl-id ${network_acl_id} \
        --egress \
        --rule-number 500 \
        --protocol tcp \
        --rule-action allow \
        --cidr-block 0.0.0.0/0 \
        --port-range From=22,To=22

echo "Done...Creating NACL entries"

export network_acl_id

