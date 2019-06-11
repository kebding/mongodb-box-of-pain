#!/bin/bash

# This script sets up and runs the Box of Pain tracing project. 

# ARGS
# $1 = filepath to painbox executable
# $2 = number of replicas in the replica set
# $3 = port number to use. each replica will use the next port, e.g.
#    if the first port is 11111, the replicas will use ports 11111, 11112, etc.
# $4 = filepath to the ycsb directory, e.g. ./ycsb-0.15.0

if [[ $# -lt 4 ]]; then
    echo "USAGE: $0 painbox-filepath num-replicas first-port ycsb-dirpath"
    exit 1
fi

PAINBOX=$1
NUM_REPLICAS=$2
let FIRST_PORT=$3
let PORT=$FIRST_PORT
YCSB_DIR=$4


# generate the replica set configuration script
echo "generating rsconf.js"
bash create_rsconf.bash $NUM_REPLICAS $FIRST_PORT

# generate Box of Pain and YCSB commands
PAIN_CMD="$PAINBOX -e mongod,--replSet,rs0,--port,$PORT,--dbpath,./replica0,--smallfiles,--oplogSize,128,--logpath,./replica0/replica0.log"

YCSB_LOAD_CMD="$YCSB_DIR/bin/ycsb.sh load mongodb -s -P $YCSB_DIR/workloads/workloada -p mongodb.url=mongodb://localhost:$PORT"

YCSB_RUN_CMD="$YCSB_DIR/bin/ycsb.sh run mongodb -s -P $YCSB_DIR/workloads/workloada -p mongodb.url=mongodb://localhost:$PORT"

mkdir replica0
for (( i = 1; i < $NUM_REPLICAS; i++ )); do
    let PORT++
    mkdir replica$i
    PAIN_CMD="$PAIN_CMD -e mongod,--replSet,rs0,--port,$PORT,--dbpath,./replica$i,--smallfiles,--oplogSize,128,--logpath,./replica$i/replica$i.log"
    YCSB_LOAD_CMD="$YCSB_LOAD_CMD,localhost:$PORT"
    YCSB_RUN_CMD="$YCSB_RUN_CMD,localhost:$PORT"
done

PAIN_CMD="$PAIN_CMD -e mongo,localhost:$FIRST_PORT,rsconf.js,!120"
YCSB_LOAD_CMD="$YCSB_LOAD_CMD/ycsb?replicaSet=rs0"
YCSB_RUN_CMD="$YCSB_RUN_CMD/ycsb?replicaSet=rs0"



echo "launching Box of Pain: $PAIN_CMD"
$PAIN_CMD &> pain.log & 

# wait while the mongod instances launch
echo "waiting 120s for mongod instances to launch"
sleep 120

echo "waiting 30s for replica set config to settle"
sleep 30
# load and run the YCSB workload
echo "running YCSB load: $YCSB_LOAD_CMD"
$YCSB_LOAD_CMD &> ycsb_load.out

sleep 10
echo "running YCSB: $YCSB_RUN_CMD"
$YCSB_RUN_CMD &> ycsb_run.out

sleep 240
