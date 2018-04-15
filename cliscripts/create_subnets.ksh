#!/bin/ksh

echo "Start...Creating private subnets"

for netnbr in {1..2}                                                                                                                       
do
    subnet_response[netnbr]=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.${netnbr}.0/24 --availability-zone ap-south-1a`
done

for netnbr in {3..4}
do
    subnet_response[netnbr]=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.${netnbr}.0/24 --availability-zone ap-south-1b`
done

for i in {1..4}
do
  subnetids[i]=`echo ${subnet_response[i]} | jq '.Subnet.SubnetId' | tr -d '"'`
  availabilityZone[i]=`echo ${subnet_response[i]} | jq '.Subnet.AvailabilityZone' | tr -d '"'`
  aws ec2 create-tags \
    --resources "${subnetids[i]}" \
    --tags "Key"="Name","Value"="PrivateSubnet-${i}-${availabilityZone[i]}" \
           "Key"="Type","Value"="ShellScript"
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

export publicsubnetid
export subnet_response 
export subnetids
