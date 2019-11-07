#!/bin/bash
cd "/home/centos/webserver"
npm install
node webapp/index.js > /dev/null 2> /dev/null < /dev/null &