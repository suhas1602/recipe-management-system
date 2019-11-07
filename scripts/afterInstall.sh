#!/bin/bash
cd "/home/centos/webserver"
npm install
pwd
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/home/centos/webserver/cloudwatch-config.json \
    -s
sudo chown centos csye6225.log
sudo chmod 664 csye6225.log    
forever start "webapp/index.js"