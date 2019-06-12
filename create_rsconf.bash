#!/bin/bash

# This script generates rsconf.js, a script that will be used to configure the
# replica set.
# The first 7 replicas are given priority=1, meaning they are all equally
# eligible to be the primary replica; any subsequent replicas are given
# priority=0, indicating that they are ineligible to become the primary.

if [[ $# -lt 2 ]]; then
    echo "USAGE: bash $0 num-replicas first-port"
    exit 1
fi

NUM_REPLICAS=$1
let PORT=$2
HOSTNAME=$(hostname)

# create the rsconf data structure
echo "rsconf = {" > rsconf.js
echo "_id: \"rs0\"," >> rsconf.js
echo "members: [" >> rsconf.js

for (( i=0; i < $NUM_REPLICAS; i++ )); do
    # add a comma between member entries 
    if [[ $i -ne 0 ]]; then
        echo "," >> rsconf.js
    fi

    echo "{_id: $i, host: \"$HOSTNAME:$PORT\", " >> rsconf.js
    
    if [[ $i -lt 7 ]]; then
        echo "priority: 1, votes: 1}" >> rsconf.js
    else
        echo "priority: 0, votes: 0}" >> rsconf.js
    fi
    
    let PORT++
done

echo "]" >> rsconf.js
echo "}" >> rsconf.js

# create the commands for the mongo shell to run
echo "rs.initiate(rsconf)" >> rsconf.js
