#!/bin/ksh


# Creating an STS role based on the STS document
echo "Start...Creating an STS role based on the STS document"

response=`aws iam create-role --role-name CloudWatch-EC2-Instance-Profile --assume-role-policy-document file://./policies/EC2-STS-Permission.json  2> /dev/null`

if [ $? == 0 ]
then
   echo "Done...Creating an STS role based on the STS document"
elif [ $? == 255 ]
then
    echo "Done...STS role based on the STS document already created"
else
    echo "Error in creating STS role based on the STS document"
fi

# Applying the role policy defined in policy document to the STS role
echo "Start...Applying the role policy defined in policy document to the STS role"

response=`aws iam put-role-policy --role-name CloudWatch-EC2-Instance-Profile --policy-name CloudWatch-EC2-Policy --policy-document file://./policies/EC2-CloudWatch-Policy.json 2> /dev/null`

if [ $? == 0 ]
then
   echo "Done...Applying the role policy defined in policy document to the STS role"
elif [ $? == 255 ]
then
    echo "Done...Role policy defined in policy document to the STS role already applied"
else
    echo "Error in applying the role policy defined in policy document to the STS role"
fi

# Creating an instance profile
echo "Start...Creating an instance profile"

response=`aws iam create-instance-profile --instance-profile-name CloudWatch-EC2-Instance-Profile 2> /dev/null`

if [ $? == 0 ]
then
   echo "Done...Creating an instance profile"
elif [ $? == 255 ]
then
    echo "Done...Instance profile already created"
else
    echo "Error in Creating an instance profile"
fi

# Associating the instance profile to the STS role
echo "Start...Associating the instance profile to the STS role"

response=`aws iam add-role-to-instance-profile --instance-profile-name CloudWatch-EC2-Instance-Profile --role-name CloudWatch-EC2-Instance-Profile 2> /dev/null`

if [ $? == 0 ]
then
   echo "Done...Associating the instance profile to the STS role"
elif [ $? == 255 ]
then
    echo "Done...Already associated the instance profile to the STS role"
else
    echo "Error in Associating the instance profile to the STS role"
fi

sleep 60
