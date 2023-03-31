#!/bin/bash
set -x

APPDIR=$(dirname $0)
source $APPDIR/docker-monitor.inc

if [ -z ${SYSLOG_SERVER} ]; then
    echo "WARNING: SYSLOG_SERVER not set, update docker-monitor.inc"
    exit 1
fi

SMS="msa-sms"
DATE_FORMAT="%Y-%m-%d %H:%M:%S"
LOGFILE=/var/log/docker-monitor.log
# jq no color and raw output
JQ="/usr/bin/jq -M -r"

# Monitor Docker events
monitor_swarm_docker_events()
{
  docker system events --filter 'scope=swarm' --format 'type={{.Type}}  status={{.Status}}  from={{.From}}  ID={{.Actor.ID}} action={{.Action}} scope={{.Scope}}  {{range $key, $val := .Actor.Attributes}}{{printf "%s=%s " $key $val }}{{end}}' | while read event
  do
    d=$(date +"$DATE_FORMAT")
    echo "$d  send syslog for event $event"
    echo "<14> $event" | nc -v -u -w1 $SYSLOG_SERVER 514
  done
}

monitor_docker_events()
{
  docker system events --filter 'scope=local' --format 'type={{.Type}}  status={{.Status}}  from={{.From}}  ID={{.ID}} action={{.Action}} scope={{.Scope}}' | grep -v "container exec_" | while read event
  do
    d=$(date +"$DATE_FORMAT")
    echo "$d  send syslog for event $event"
    echo "<14> $event" | nc -v -u -w1 $SYSLOG_SERVER 514
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
