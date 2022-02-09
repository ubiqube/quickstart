#!/bin/bash

set -e

# set only if it was called directly
if [ $0 = "./scripts/swarm-fix-all-nodes.sh" ]; then
    ssh_user=$USER
fi

fix_swarm_route() {
    swarm_fix='./scripts/swarm-fix-route.sh'

    for node  in $(docker node ls -q); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')

        echo 'Copying swarm-fix-route file to nodes...'
        scp ${swarm_fix} ${ssh_user}@${node_ip}:/tmp/
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -a"
    done
}

# call if it was called directly
if [ $0 = "./scripts/swarm-fix-all-nodes.sh" ]; then
    fix_swarm_route
fi
