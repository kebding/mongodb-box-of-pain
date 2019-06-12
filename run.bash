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

PAIN_CMD="$PAIN_CMD -e mongo,localhost:$FIRST_PORT,rsconf.js,!60"
YCSB_LOAD_CMD="$YCSB_LOAD_CMD/ycsb?replicaSet=rs0"
YCSB_RUN_CMD="$YCSB_RUN_CMD/ycsb?replicaSet=rs0"



echo "launching Box of Pain: $PAIN_CMD"
$PAIN_CMD &> pain.log & 

# wait while the mongod instances launch
echo "waiting 60s for mongod instances to launch"
sleep 60

echo "waiting 30s for replica set config to settle"
sleep 30

# inserting some data before the workload test
echo "inserting a document to check later for durability"
mongo localhost:$FIRST_PORT insert.js --quiet
sleep 1

# load and run the YCSB workload
echo "running YCSB load: $YCSB_LOAD_CMD"
$YCSB_LOAD_CMD &> ycsb_load.out

sleep 5
echo "running YCSB: $YCSB_RUN_CMD"
$YCSB_RUN_CMD &> ycsb_run.out
sleep 1

# check if the previously-stored document still exists and that the replicas
# agree on its value
let PORT=$FIRST_PORT
AGREE="true"
for (( i = 0; i < $NUM_REPLICAS; i++ )); do
    QUERY_OUT=$(mongo localhost:$PORT query.js --quiet)
    echo "replica$i: output = $QUERY_OUT"
    if [[ -z $(grep '"key" : "foo"' <(echo $QUERY_OUT)) || -z $(grep '"value" : "bar"' <(echo $QUERY_OUT)) ]];
    then
        echo "durability test failed for replica $i"
    else
        echo "durability test passed for replica $i"
    fi
    if [[ $i -gt 1 ]]; then
        if [[ $PREV_QUERY_OUT != $QUERY_OUT ]]; then
            AGREE="false"
        fi
    fi
    let PORT++
    PREV_QUERY_OUT=$QUERY_OUT
done

if [[ $AGREE == "true" ]]; then
    echo "all replicas agreed on the value"
else
    echo "not all replicas agreed on the value"
fi
