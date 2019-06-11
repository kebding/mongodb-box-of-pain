#!/bin/bash

# This script installs the prerequisites for running this project.
# 
# This script should be run from the mongodb-box-of-pain/ directory.

echo "installing mongodb"
apt --assume-yes install mongodb

echo "installing YCSB benchmark test"
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.15.0/ycsb-0.15.0.tar.gz && tar xfvz ycsb-0.15.0.tar.gz
