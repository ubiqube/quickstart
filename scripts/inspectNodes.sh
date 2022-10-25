#!/bin/bash
NODES=$(docker node ls --format '{{.Hostname}}')
#NODES=$(docker node ls -f "role=worker" -f "node.label=worker=app" --format '{{.Hostname}}')
docker node inspect --format '{{printf "%-32s%-16s%-16s%s" .Description.Hostname .Status.Addr .Status.State .Spec.Labels}}' $NODES
