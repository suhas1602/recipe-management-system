#!/bin/bash
cd "/home/centos/webserver"
npm install
pwd
sudo node webapp/index.js > /dev/null 2> /dev/null < /dev/null &