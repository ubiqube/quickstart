#!/bin/bash

SMS="msa-sms"
DATE_FORMAT="%Y-%m-%d %H:%M:%S"
LOGFILE=/var/log/docker-monitor.log

# jq no color and raw output
JQ="/usr/bin/jq -M -r"

# Monitor Docker events
monitor_swarm_docker_events()
{
  DOCKER_SERVICE_SMS="${DOCKER_STACK_NAME}_${SMS}"

  docker events --format '{{ .Time }} {{ .Action }} {{ .Type }} {{ .ID }}'  | while read event
  do
      d=$(date +"$DATE_FORMAT")
      echo "$d  send syslog for event $event"
  done
}

monitor_docker_events()
{
  local state="healthy"
  DOCKER_CONTAINER_SMS=$(docker ps --format {{.Names}} -f name=${SMS})

  docker events --format '{{ .Time }} {{ .Action }} {{ .Type }} {{ .ID }}'  | while read event
  do
    d=$(date +"$DATE_FORMAT")
    echo "$d  send syslog for event $event"
  done
}

# USER does not exist if the script is executed as a service (systemd)
[ -z "$USER" ] && export USER=root

# Get the swarm name if any
DOCKER_STACK_NAME=''
STACK_NAMES=$(docker stack ls --format {{.Name}} 2>/dev/null)
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

exec >>${LOGFILE} 2>&1

if [ -n "$DOCKER_STACK_NAME" ]; then
  monitor_swarm_docker_events
else
  monitor_docker_events
fi
