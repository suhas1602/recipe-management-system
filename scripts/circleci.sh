#!/bin/bash
fileName=$(ls "../" | grep zip)
echo $fileName
aws s3 cp "../$fileName" "s3://codedeploy.suhaspasricha.com/$fileName"

ETag=$(aws s3api head-object --bucket codedeploy.suhaspasricha.com --key $fileName --query ETag --output text)

ETag="${ETag%\"}"
ETag="${ETag#\"}"
echo $ETag

deploymentId=$(aws deploy create-deployment --application-name csye6225-webapp --deployment-config-name CodeDeployDefault.AllAtOnce --deployment-group-name csye6225-webapp-deployment --description "Webapp deployment" --s3-location bucket=codedeploy.suhaspasricha.com,bundleType=zip,eTag=$ETag,key=$fileName | jq '.deploymentId')

deploymentId="${deploymentId%\"}"
deploymentId="${deploymentId#\"}"
echo $deploymentId

aws deploy wait deployment-successful --deployment-id $deploymentId