#!/bin/bash
STACK_NAME=$(docker stack ls --orchestrator swarm --format '{{.Name}}')
for node in $(docker node ls --format '{{.Hostname}}'); do
  echo "#################### $node #######################"
  docker stack ps -f node=$node -f desired-state=Running --format '{{printf "%-16s%-32s%s" .ID .Name .CurrentState}}' $STACK_NAME
  echo
done
