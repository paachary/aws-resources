#!/bin/bash
echo "Creating application 'CodeDeployGitHub-App' using code deploy CLI".

response=`aws deploy create-application --application-name CodeDeployGitHub-App`

roleArn=`aws iam get-role --role-name CodeDeployServiceRole --query "Role.Arn"|tr -d '"'`

echo "Creating deployment group for the application 'CodeDeployGitHub-App' using code deploy CLI".

response=`aws deploy create-deployment-group --application-name CodeDeployGitHub-App --ec2-tag-filters Key=DeploymentGroup,Type=KEY_AND_VALUE,Value=CodeDeployGroup --deployment-group-name CodeDeployGitHub-DepGrp --service-role-arn ${roleArn}`

echo "Creating the deployment using the latest commit-id from githib repository where the application code is located"

response=`aws deploy create-deployment \
  --application-name CodeDeployGitHub-App \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --deployment-group-name CodeDeployGitHub-DepGrp \
  --description "My GitHub deployment" \
  --github-location repository=paachary/aws-applications,commitId=8ca92943e00846e150842e3933fe023ac9f69f3d`
