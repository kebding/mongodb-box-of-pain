#!/bin/bash

# This script installs the prerequisites for running this project.
# 
# This script should be run from the mongodb-box-of-pain/ directory.

echo "installing mongodb"
apt --assume-yes install mongodb

echo "installing YCSB benchmark test"
(git clone git://github.com/brianfrankcooper/YCSB.git && \
    cd YCSB && mvn clean package; cd ../)

