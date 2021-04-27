#!/bin/bash

BASENAME=${1:-baa}
NUM_PROJECTS=${2:-250}

echo "Starting run basename: $BASENAME number of projects: $NUM_PROJECTS"
date

for ((i=0; i<NUM_PROJECTS; i++)); do
  oc new-project "${BASENAME}${i}" > /dev/null && echo "Created project ${BASENAME}${i}"
done
echo "Creation cycle complete"
date

echo "Sleeping 10 mins..."
sleep 10m

date
for ((i=0; i<NUM_PROJECTS; i++)); do
  oc delete project "${BASENAME}${i}"
done
echo "Delete cycle complete"

echo "Waiting for projects to terminate..."
PROJECTS_TERMINATING=999
while [ $PROJECTS_TERMINATING -gt 0 ]; do
  PROJECTS_TERMINATING=$(oc get projects | grep -c "$BASENAME")
  echo "$(date) - Projects still terminating: $PROJECTS_TERMINATING"
  if [ $PROJECTS_TERMINATING -gt 0 ]; then
    sleep 30s;
  fi
done

