#!/bin/bash
PID=$(lsof -i:3000 | awk '/node/ {print $2}')
echo $PID
if [ -z "$PID" ]
then
        echo "\$PID is empty"
else
        echo "\$PID is NOT empty"
        forever stop $PID
fi
