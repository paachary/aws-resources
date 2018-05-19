#!/bin/ksh

echo "Start...Removing role from instance profile"

response=`aws iam remove-role-from-instance-profile --instance-profile-name CloudWatch-EC2-Instance-Profile --role-name CloudWatch-EC2-Instance-Profile 2> /dev/null`

echo "Done...Removing role from instance profile"

echo "Start...Removing instance profile"

response=`aws iam delete-instance-profile --instance-profile-name CloudWatch-EC2-Instance-Profile 2> /dev/null`

echo "Done...Removing instance profile"

echo "Start...Removing Role policy"

response=`aws iam delete-role-policy --role-name CloudWatch-EC2-Instance-Profile --policy-name CloudWatch-EC2-Policy 2> /dev/null`

echo "Done...Removing Role policy"

echo "Start...Deleting the role"

response=`aws iam delete-role --role-name CloudWatch-EC2-Instance-Profile 2> /dev/null`

echo "Done...Deleting the role"
