#!/bin/ksh

echo "Start...associating internet gateway to Public Route Table"

response=`aws ec2 create-route \
        --route-table-id ${Publicroutetableid} \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id ${igwid}`

echo "Done...associating internet gateway to Public Route Table"

echo "Start...associating NAT instance to Private Route Table"

response=`aws ec2 create-route \
        --route-table-id ${privateroutetableid} \
        --destination-cidr-block 0.0.0.0/0 \
        --instance-id ${NATinstanceId}`

echo "Done...associating NAT instance to Private Route Table"


