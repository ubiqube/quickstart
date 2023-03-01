#!/bin/bash
# Get the swarm name if any
DOCKER_STACK_NAME=''
STACK_NAMES=$(docker stack ls --orchestrator swarm --format {{.Name}} 2>/dev/null)
if [ $? -eq 0 ]; then
  for s in $STACK_NAMES; do
    docker stack ps "$s" --filter "name=${s}_${SMS}" -q >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      # this is the right stack
      DOCKER_STACK_NAME="$s"
      break
    fi
  done
fi

if [ -n "$DOCKER_STACK_NAME" ]; then
  for node in $(docker node ls --format '{{.Hostname}}'); do
    echo "#################### $node #######################"
    docker stack ps -f node=$node -f desired-state=Running --format '{{printf "%-16s%-32s%s" .ID .Name .CurrentState}}' $DOCKER_STACK_NAME
    echo
  done
else
  echo "No MSA stack found"
fi
