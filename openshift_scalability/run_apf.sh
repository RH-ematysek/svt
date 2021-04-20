#!/bin/bash

BASENAME=${1:-mva}
NUM_PROJECTS=${2:-250}
PARALLEL=${3:-10}

CONFIG_TEMPLATE=config/apf_template.yaml

cp $CONFIG_TEMPLATE config/apf_run.yaml

sed -i "s/BASENAME/$BASENAME/g" config/apf_run.yaml
sed -i "s/NUM_PROJECTS/$NUM_PROJECTS/g" config/apf_run.yaml

date
SECONDS=0
./cluster-loader.py -f config/apf_run.yaml -p "$PARALLEL"
duration=$SECONDS
echo "Time taken: $duration"
date

for i in {0..10}; do oc get pods -A | grep -v Running | grep -v Completed; echo; sleep 1m; done
date

for ((i=0; i<NUM_PROJECTS; i++)); do
  oc delete project "${BASENAME}${i}"
done

date