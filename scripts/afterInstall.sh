#!/bin/bash
cd "/home/centos/webserver"
npm install
pwd
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/home/centos/webserver/cloudwatch-config.json \
    -s

if [ ! -f "/home/centos/webserver/csye6225.log" ]
then
    echo "Creating log file"
    touch "/home/centos/webserver/csye6225.log"
fi

sudo chown centos "/home/centos/webserver/csye6225.log"
sudo chmod 664 csye6225.log   
source /etc/environment
echo $DB_USER
echo $DB_HOST_NAME 
pm2 start "/home/centos/webserver/webapp/index.js" --name="csye6225-webapp"