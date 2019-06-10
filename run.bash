#!/bin/bash

# This script sets up and runs the Box of Pain tracing project. 

# ARGS
# $1 = filepath to painbox executable
# $2 = number of replicas in the replica set
# $3 = port number to use. each replica will use the next port, e.g.
#    if the first port is 11111, the replicas will use ports 11111, 11112, etc.

if [[ $# -lt 3 ]]; then
    echo "USAGE: $0 painbox-filepath num-replicas first-port"
    exit 1
fi

PAINBOX=$1
NUM_REPLICAS=$2
let FIRST_PORT=$3
let PORT=$FIRST_PORT

# launch Box of Pain
echo "starting Box of Pain and mongod instances"
PAIN_CMD="$PAINBOX -e mongod,--replSet,rs0,--port,$PORT,--dbpath,./replica0,--smallfiles,--oplogSize,128,--logpath,./replica0/replica0.log"

mkdir replica0
for (( i = 1; i < $NUM_REPLICAS; i++ )); do
    let PORT++
    mkdir replica$i
    PAIN_CMD="$PAIN_CMD -e mongod,--replSet,rs0,--port,$PORT,--dbpath,./replica$i,--smallfiles,--oplogSize,128,--logpath,./replica$i/replica$i.log"
done

echo "running command: $PAIN_CMD"
$PAIN_CMD &> pain.log & 

# wait while the mongod instances launch
echo "waiting 120s for mongod instances to launch"
sleep 120

# generate the replica set configuration script
echo "generating rsconf.js"
bash create_rsconf.bash $NUM_REPLICAS $FIRST_PORT

# connect to a replica
echo "initiating the replica set"
mongo localhost:$FIRST_PORT rsconf.js
