#!/bin/bash

SMS="msa-sms"
RSYSLOG="msa-rsyslog"
DATE_FORMAT="%Y-%m-%d %H:%M:%S"
LOGFILE=/var/log/sms-monitor.log

# jq no color and raw output
JQ="/usr/bin/jq -M -r"

get_json_field()
{
    FIELD=$(echo "$1" | $JQ "$2")
}

# Monitor Docker events
monitor_swarm_docker_events()
{
  DOCKER_SERVICE_SMS="${DOCKER_STACK_NAME}_${SMS}"
  DOCKER_SERVICE_RSYSLOG="${DOCKER_STACK_NAME}_${RSYSLOG}"

  docker events --filter 'scope=swarm' --filter 'event=update' --filter "service=${DOCKER_SERVICE_SMS}" --format '{{json .}}' | while read event
  do
    get_json_field "$event" '.Actor.Attributes."updatestate.new"'
    if [ "$FIELD" = "completed" ]; then
      d=$(date +"$DATE_FORMAT")
      echo "$d  update ${DOCKER_SERVICE_RSYSLOG} service"
      docker service update -q --force ${DOCKER_SERVICE_RSYSLOG}
      d=$(date +"$DATE_FORMAT")
      echo "$d  update ${DOCKER_SERVICE_RSYSLOG} service DONE"

      d=$(date +"$DATE_FORMAT")
      echo "$d  execute swarm-fix-all-nodes.sh"
      pushd /root/quickstart/
      ./scripts/swarm-fix-all-nodes.sh
      popd
      d=$(date +"$DATE_FORMAT")
      echo "$d  swarm-fix-all-nodes.sh DONE"
    fi
  done
}

monitor_docker_events()
{
  local state="healthy"
  DOCKER_CONTAINER_SMS=$(docker ps --format {{.Names}} -f name=${SMS})
  DOCKER_CONTAINER_RSYSLOG=$(docker ps --format {{.Names}} -f name=${RSYSLOG})

  docker events --filter 'scope=local' --filter "service=${DOCKER_CONTAINER_SMS}" --format '{{json .}}' | while read event
  do
    get_json_field "$event" '.status'
    if [ "$FIELD" = "restart" ]; then
      state="restart"
    elif [ "$FIELD" = "health_status: healthy" ]; then
      if [ "$state" = "restart" ]; then
        d=$(date +"$DATE_FORMAT")
        echo "$d  restart ${DOCKER_CONTAINER_RSYSLOG}"
        docker container restart ${DOCKER_CONTAINER_RSYSLOG}
        d=$(date +"$DATE_FORMAT")
        echo "$d  update ${DOCKER_CONTAINER_RSYSLOG} service DONE"
        state="healthy"
      fi
    fi
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
