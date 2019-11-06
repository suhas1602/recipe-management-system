#!/bin/bash
cd "/home/centos/webserver"
npm install
forever start "webapp/index.js"