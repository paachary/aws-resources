#!/bin/bash
cd /home/ec2-user
curl -O https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto