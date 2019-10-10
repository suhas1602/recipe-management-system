#!/bin/bash
AWS_REGION=$1
CIDR_BLOCK=$2
SUBNET_BLOCK_1=$3
SUBNET_BLOCK_2=$4
SUBNET_BLOCK_3=$5
VPC_NAME=$6
PROFILE=$7

res="$(aws ec2 create-vpc --cidr-block $CIDR_BLOCK --profile ${PROFILE} | jq '.Vpc.VpcId')"

vpcId="${res%\"}"
vpcId="${vpcId#\"}"

echo "VpcId: ${vpcId}"

aws ec2 create-tags --resources ${vpcId} --tags Key=Name,Value=${VPC_NAME} --profile ${PROFILE}

availability_zone_1="${AWS_REGION}a" 
subnet1="$(aws ec2 create-subnet --vpc-id ${vpcId} --cidr-block ${SUBNET_BLOCK_1} --availability-zone ${availability_zone_1} --profile ${PROFILE} | jq -r '.Subnet.SubnetId')"  

availability_zone_2="${AWS_REGION}b" 
subnet2="$(aws ec2 create-subnet --vpc-id ${vpcId} --cidr-block ${SUBNET_BLOCK_2} --availability-zone ${availability_zone_2} --profile ${PROFILE} | jq -r '.Subnet.SubnetId')"

availability_zone_3="${AWS_REGION}c" 
subnet3="$(aws ec2 create-subnet --vpc-id ${vpcId} --cidr-block ${SUBNET_BLOCK_3} --availability-zone ${availability_zone_3} --profile ${PROFILE} | jq -r '.Subnet.SubnetId')"

gatewayId="$(aws ec2 --profile dev create-internet-gateway | jq '.InternetGateway.InternetGatewayId')"

gatewayId="${gatewayId%\"}"
gatewayId="${gatewayId#\"}"

echo "GatewayId: ${gatewayId}"

aws ec2 attach-internet-gateway --internet-gateway-id ${gatewayId} --vpc-id ${vpcId} --profile ${PROFILE}

routeTableId="$(aws ec2 --profile ${PROFILE} describe-route-tables --filters Name=vpc-id,Values=${vpcId} | jq '.RouteTables[0].RouteTableId')"

routeTableId="${routeTableId%\"}"
routeTableId="${routeTableId#\"}"

echo "RouteTableId: ${routeTableId}"

aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --gateway-id ${gatewayId} --route-table-id ${routeTableId} --profile ${PROFILE}

aws ec2 associate-route-table --route-table-id ${routeTableId} --subnet-id ${subnet1} --profile ${PROFILE}
aws ec2 associate-route-table --route-table-id ${routeTableId} --subnet-id ${subnet2} --profile ${PROFILE}
aws ec2 associate-route-table --route-table-id ${routeTableId} --subnet-id ${subnet3} --profile ${PROFILE}

echo "Network infrastructure created successfully"