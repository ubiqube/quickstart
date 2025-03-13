#!/bin/bash

# the following command does not work as expected!
#  docker inspect $i --format '{{$ip := (index .NetworkSettings.Networks .HostConfig.NetworkMode).IPAddress}} {{$health := "undefined"}} {{if .State.Health}}{{$health = .State.Health.Status}}{{end}} {{printf "%-32s%-16s%-16s%-20s%s" .Name .State.Status $health $ip .NetworkSettings.SandboxKey}}'

for i in $(docker ps -a --format '{{printf "%s" .ID}}'); do
  _NAME=$(docker inspect $i --format '{{.Name}}')
  NAME=${_NAME#/*}
  STATUS=$(docker inspect $i --format '{{.State.Status}}')
  HEALTH=$(docker inspect $i --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{"undefined"}}{{end}}')
  IP=$(docker inspect $i --format '{{(index .NetworkSettings.Networks .HostConfig.NetworkMode).IPAddress}}')
  NS=$(docker inspect $i --format '{{.NetworkSettings.SandboxKey}}')
  printf "%-32s%-16s%-16s%-20s%s\n" $NAME $STATUS $HEALTH $IP $NS
done
