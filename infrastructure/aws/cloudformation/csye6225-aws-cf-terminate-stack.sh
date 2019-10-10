#!/bin/bash
STACK_NAME=$1
PROFILE=$2

aws cloudformation delete-stack --stack-name ${STACK_NAME} --profile ${PROFILE}

aws cloudformation wait stack-delete-complete --stack-name ${STACK_NAME} --profile ${PROFILE}

if [ $? != 0 ]; then
    echo "Stack deletion failed"
else
    echo "Stack deletion successfully"
fi      