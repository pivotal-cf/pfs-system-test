#!/bin/bash

source ./util.sh
source ./init.sh $CLUSTER

for test in uppercase; do
  dir=`dirname "${BASH_SOURCE[0]}"`
  echo "Current function scenario: $test"
  source $dir/$test/run.sh
done