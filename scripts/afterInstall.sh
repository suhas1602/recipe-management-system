#!/bin/bash
cd "/home/centos/webserver"
npm install
pwd
node webapp/index.js > /dev/null 2> /dev/null < /dev/null &
lsof -i:3000