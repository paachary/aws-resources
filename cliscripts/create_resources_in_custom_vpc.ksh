#!/bin/ksh
vpcName="Custom VPC"
routeTableName="$vpcName RouteTable"
igwName="$vpcName IGW"

echo "Start...Creating a custom VPC"

response=`aws ec2 create-vpc --cli-input-json file://vpc_input.json`

vpcid=`echo $response | jq '.Vpc.VpcId' | tr -d '"'`

#vpcid=`aws ec2 describe-vpcs --region ap-south-1  | grep VpcId | awk -F'["-,]' '{print $4 }'`

aws ec2 create-tags \
      --resources "${vpcid}" \
      --tags "Key"="Name","Value"="${vpcName}" \
        "Key"="Type","Value"="ShellScript"

aws ec2 modify-vpc-attribute --vpc-id ${vpcid} \
        --enable-dns-hostnames "{\"Value\":true}"

aws ec2 modify-vpc-attribute --vpc-id ${vpcid} \
        --enable-dns-support "{\"Value\":true}"

echo "Done...Creating a custom VPC -${vpcid} "

echo "Start...Creating a custom internet gateway"

igw=`aws ec2 create-internet-gateway`

igwid=`echo $igw| awk -F'["-,:]' '/,/{gsub(/ /, "", $0);print $12 }'`

aws ec2 create-tags \
      --resources "$igwid" \
      --tags "Key"="Name","Value"="$igwName" \
        "Key"="Type","Value"="ShellScript"

aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igwid

echo "Done...Creating a custom internet gateway - $igwid and attaching it to VPC : ${vpcid}"

echo "Start...Creating private subnets"

for netnbr in {1..2}
do
    subnet_response[netnbr]=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.${netnbr}.0/24 --availability-zone ap-south-1a`
done

for netnbr in {3..4}
do
    subnet_response[netnbr]=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.${netnbr}.0/24 --availability-zone ap-south-1b`
done

echo "End...Creating private subnets"

echo "Start...Creating a public subnet"

public_subnet_response=`aws ec2 create-subnet --vpc-id ${vpcid} --cidr-block 10.0.5.0/24 --availability-zone ap-south-1b`
publicsubnetid=`echo ${public_subnet_response} | jq '.Subnet.SubnetId' | tr -d '"'`
aws ec2 create-tags \
      --resources "${publicsubnetid}" \
      --tags "Key"="Name","Value"="PublicSubnet-${availabilityZone[i]}" \
        "Key"="Type","Value"="ShellScript"

aws ec2 modify-subnet-attribute \
        --subnet-id ${publicsubnetid} \
        --map-public-ip-on-launch

echo "Done...Creating a public subnet - ${publicsubnetid}"

echo "Start...Creating private route table"

routetable_response=`aws ec2 create-route-table --vpc-id ${vpcid}`

privateroutetableid=`echo $routetable_response | jq '.RouteTable.RouteTableId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${privateroutetableid}" \
      --tags "Key"="Name","Value"="${routeTableName}" \
        "Key"="Type","Value"="ShellScript"

echo "Done...Creating private route table - ${privateroutetableid}"

echo "Start...Creating Public route table"

routetable_response=`aws ec2 create-route-table --vpc-id ${vpcid}`

Publicroutetableid=`echo $routetable_response | jq '.RouteTable.RouteTableId' | tr -d '"'`

aws ec2 create-tags \
      --resources "${Publicroutetableid}" \
      --tags "Key"="Name","Value"="Public Route Table" \
        "Key"="Type","Value"="ShellScript"

echo "Done...Creating Public route table - ${Publicroutetableid}"

echo "Start...Associating private subnets to the private route table"

for i in {1..4}
do
    subnetids[i]=`echo ${subnet_response[i]} | jq '.Subnet.SubnetId' | tr -d '"'`
    availabilityZone[i]=`echo ${subnet_response[i]} | jq '.Subnet.AvailabilityZone' | tr -d '"'`
    aws ec2 create-tags \
      --resources "${subnetids[i]}" \
      --tags "Key"="Name","Value"="PrivateSubnet-${i}-${availabilityZone[i]}" \
        "Key"="Type","Value"="ShellScript"
    assoc_rt_response[i]=`aws ec2 associate-route-table --route-table-id $privateroutetableid --subnet-id ${subnetids[i]}`
done

echo "Done...Associating private subnets to the private route table"

echo "Start...Associating public subnet to the Public route table"

assoc_rt_response=`aws ec2 associate-route-table --route-table-id ${Publicroutetableid} --subnet-id ${publicsubnetid}`

echo "Done...Associating public subnets to the Public route table"

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

echo "Start...Associating subnets with new network ACL id"

response=`aws ec2 describe-network-acls  |  jq '.NetworkAcls[].Associations[].NetworkAclAssociationId'| tr -d '"'| awk -v env_var=${network_acl_id} '{cmd="aws ec2 replace-network-acl-association --association-id " $1 " --network-acl-id " env_var ; system(cmd)}'`

echo "Done...Associating subnets with new network ACL id"

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
        --protocol tcp --port 22 --cidr 0.0.0.0/0`

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 80 --cidr 0.0.0.0/0`

response=`aws ec2 authorize-security-group-ingress \
        --group-id ${security_grp_id} \
        --protocol tcp --port 443 --cidr 0.0.0.0/0`

echo "Start...associating internet gateway to Public Route Table"

response=`aws ec2 create-route \
        --route-table-id ${Publicroutetableid} \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id ${igwid}`

echo "Done...associating internet gateway to Public Route Table"

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

echo "Start...associating NAT instance to Private Route Table"

response=`aws ec2 create-route \
        --route-table-id ${privateroutetableid} \
        --destination-cidr-block 0.0.0.0/0 \
        --instance-id ${NATinstanceId}`

echo "Done...associating NAT instance to Private Route Table"



