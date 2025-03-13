#!/bin/bash
for svc in $(docker service ls --format '{{print .ID}}'); do
  docker inspect $svc --format '{{printf "%-32s" .Spec.Name}} {{range .Endpoint.VirtualIPs}}{{printf "%-32s" .Addr}}{{end}}'
done
