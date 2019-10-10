#!/bin/bash
STACK_NAME=$1
TEMPLATE_FILE=$2
AWS_REGION=$3
CIDR_BLOCK=$4
SUBNET_BLOCK1=$5
SUBNET_BLOCK2=$6
SUBNET_BLOCK3=$7
VPC_NAME=$8
PROFILE=$9

availabilityZone1="${AWS_REGION}a"
availabilityZone2="${AWS_REGION}b"
availabilityZone3="${AWS_REGION}c"

aws cloudformation create-stack --profile ${PROFILE} --stack-name ${STACK_NAME} --template-body ${TEMPLATE_FILE} --parameters ParameterKey=CidrBlock,ParameterValue=${CIDR_BLOCK} ParameterKey=VpcName,ParameterValue=${VPC_NAME} \
    ParameterKey=SubnetBlock1,ParameterValue=${SUBNET_BLOCK1} ParameterKey=SubnetBlock2,ParameterValue=${SUBNET_BLOCK2} ParameterKey=SubnetBlock3,ParameterValue=${SUBNET_BLOCK3} ParameterKey=AvailabilityZone1,ParameterValue=${availabilityZone1} \
    ParameterKey=AvailabilityZone2,ParameterValue=${availabilityZone2} ParameterKey=AvailabilityZone3,ParameterValue=${availabilityZone3}
   
aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME} --profile ${PROFILE}

if [ $? != 0 ]; then
    echo "Stack creation failed"
else
    echo "Stack creation successful"
fi        