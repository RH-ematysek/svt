#!/bin/bash

BASENAME=${1:-baa}
NUM_PROJECTS=${2:-1000}
num_procs=${3:-10}
sleep_mins=${4:-5}

echo "Starting run basename: $BASENAME"
echo "number of projects: $NUM_PROJECTS"
echo "Parallel processes: $num_procs"
echo "Sleep time between create cycle and delete cycle: $sleep_mins"
echo "Writing subprocess logs to ./op.log"
if [ -e op.log ]; then
  echo "op.og exists, subprocess logs will be appended"
  echo "$(date) - New Run" >> op.log
fi

SECONDS=0

num_jobs="\j"  # The prompt escape for number of jobs currently running
echo "$(date) - Create cycle start"
for ((i=0; i<NUM_PROJECTS; i++)); do
  while (( ${num_jobs@P} >= num_procs )); do
    wait -n
  done
  oc new-project --skip-config-write "${BASENAME}${i}" > /dev/null && echo "Created project ${BASENAME}${i}" &>> op.log &
done
echo "$(date) - Create cycle complete"

echo "Output operator and node status"
oc get co
oc get nodes

echo "Sleeping $sleep_mins mins..."
sleep "${sleep_mins}m"

echo "Output operator and node status"
oc get co
oc get nodes

echo "$(date) - Delete cycle start"
#oc delete ns -l test=badactor
for ((i=0; i<NUM_PROJECTS; i++)); do
  while (( ${num_jobs@P} >= num_procs )); do
    wait -n
  done
  oc delete project "${BASENAME}${i}" >> op.log &
done
echo "$(date) - Delete cycle complete"

echo "Waiting for projects to terminate..."
PROJECTS_TERMINATING=999
while [ $PROJECTS_TERMINATING -gt 0 ]; do
  PROJECTS_TERMINATING=$(oc get projects | grep -c "$BASENAME")
  echo "$(date) - Projects still terminating: $PROJECTS_TERMINATING"
  if [ $PROJECTS_TERMINATING -gt 0 ]; then
    sleep 30s;
  fi
done

DURATION=$SECONDS


echo "Output operator and node status"
oc get co
oc get nodes

echo "Time taken: $DURATION"