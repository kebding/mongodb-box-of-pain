#!/bin/bash

# This script cleans up the results of previous tests.
# It may need to be run as root.

pkill mongo
sleep 1
rm -rf replica*
rm rsconf.js
