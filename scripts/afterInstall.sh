#!/bin/bash
cd "/home/centos/webserver"
npm install
pwd
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/home/centos/webserver/cloudwatch-config.json \
    -s
sudo node webapp/index.js > /dev/null 2> /dev/null < /dev/null &