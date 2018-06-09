#!/bin/bash
aws deploy create-application --application-name CodeDeployGitHub-App

roleArn=`aws iam get-role --role-name CodeDeployServiceRole --query "Role.Arn"|tr -d '"'`

aws deploy create-deployment-group --application-name CodeDeployGitHub-App --ec2-tag-filters Key=DeploymentGroup,Type=KEY_AND_VALUE,Value=CodeDeployGroup --deployment-group-name CodeDeployGitHub-DepGrp --service-role-arn ${roleArn}

aws deploy create-deployment \
  --application-name CodeDeployGitHub-App \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --deployment-group-name CodeDeployGitHub-DepGrp \
  --description "My GitHub deployment" \
  --github-location repository=paachary/aws-applications,commitId=9f6d5a5f9de0cc014c3191ce78c1b3a6e31b02f5
