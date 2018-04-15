#!/bin/ksh

echo "Start...Associating subnets with new network ACL id"

response=`aws ec2 describe-network-acls  |  jq '.NetworkAcls[].Associations[].NetworkAclAssociationId'| tr -d '"'| awk -v env_var=${network_acl_id} '{cmd="aws ec2 replace-network-acl-association --association-id " $1 " --network-acl-id " env_var ; system(cmd)}'`

echo "Done...Associating subnets with new network ACL id"


