#!/bin/bash

# This script cleans up the results of previous tests.
# It may need to be run as root.

pkill mongo
pkill painbox
sleep 1
rm -rf replica*
rm -f rsconf.js
rm -f pain.log
rm -f ycsb_load.log
rm -f ycsb_run.log
