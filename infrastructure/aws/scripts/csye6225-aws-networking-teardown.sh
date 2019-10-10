#!/bin/bash
VPC_NAME=$1
PROFILE=$2

vpcId="$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=${VPC_NAME} --profile ${PROFILE} | jq '.Vpcs[0].VpcId')"

vpcId="${vpcId%\"}"
vpcId="${vpcId#\"}"

echo "VpcId: ${vpcId}"

routeTableId="$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=${vpcId} --profile ${PROFILE} | jq .RouteTables[0].RouteTableId)"

routeTableId="${routeTableId%\"}"
routeTableId="${routeTableId#\"}"

echo "RouteTableId: ${routeTableId}"

aws ec2 delete-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${routeTableId} --profile ${PROFILE}

gatewayId="$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=${vpcId} --profile ${PROFILE} | jq '.InternetGateways[0].InternetGatewayId')"

gatewayId="${gatewayId%\"}"
gatewayId="${gatewayId#\"}"

echo "GatewayId: ${gatewayId}"

aws ec2 detach-internet-gateway --internet-gateway-id ${gatewayId} --vpc-id ${vpcId} --profile ${PROFILE}

aws ec2 delete-internet-gateway --internet-gateway-id ${gatewayId} --profile ${PROFILE}

res="$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpcId} --profile ${PROFILE} | jq -r '.Subnets[] | .SubnetId')"

for subnetId in $res
do
    echo "Deleting subnet: ${subnetId}"
    aws ec2 delete-subnet --subnet-id ${subnetId} --profile ${PROFILE}
done    

aws ec2 delete-vpc --vpc-id ${vpcId} --profile ${PROFILE}

echo "Networking teardown done successfully"