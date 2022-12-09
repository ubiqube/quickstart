#!/bin/bash

# Monitor all Docker events
docker events --filter 'scope=swarm' --filter 'event=update' --filter 'service=ha_msa-sms' --since '2m' | while read event
do
    pushd /root/quickstart/
    ./scripts/swarm-fix-all-nodes.sh
    popd
    sleep 20
done
