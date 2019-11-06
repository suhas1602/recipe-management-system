#!/bin/bash

if [ -d "/home/centos/webserver" ]
then
    echo "Remove directory"
    sudo rm -r "/home/centos/webserver"
fi
echo "Create directory"
mkdir "/home/centos/webserver"