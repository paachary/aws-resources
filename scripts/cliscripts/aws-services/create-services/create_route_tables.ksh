#!/bin/ksh

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


## Association subnets to the Route tables

echo "Start...Associating private subnets to the private route table"

for i in {1..4}
do
    assoc_rt_response[i]=`aws ec2 associate-route-table --route-table-id $privateroutetableid --subnet-id ${subnetids[i]}`
done

echo "Done...Associating private subnets to the private route table"

echo "Start...Associating public subnets to the Public route table"

assoc_rt_response=`aws ec2 associate-route-table --route-table-id ${Publicroutetableid} --subnet-id ${publicsubnetid}`

assoc_rt_response=`aws ec2 associate-route-table --route-table-id ${Publicroutetableid} --subnet-id ${publicsubnetid1}`

echo "Done...Associating public subnets to the Public route table"

export Publicroutetableid
export privateroutetableid
