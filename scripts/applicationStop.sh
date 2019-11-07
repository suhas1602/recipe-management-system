#!/bin/bash
ID=$(pm2 list | awk '/csye6225-webapp/ {print $2}')
echo $ID
if [ -z "$ID" ]
then
        echo "\$PID is empty"
else
        echo "\$PID is NOT empty"
        pm2 stop "csye6225-webapp"
        pm2 delete "csye6225-webapp"
fi
