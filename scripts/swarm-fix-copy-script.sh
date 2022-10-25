#!/bin/bash

set -e

# set only if it was called directly
if [ $0 = "./scripts/swarm-fix-copy-script.sh " ]; then
    ssh_user=$USER
fi

fix_swarm_route() {
    swarm_fix='./scripts/swarm-fix-route.sh'

    for node  in $(docker node ls -q); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')

        echo 'Copying swarm-fix-route file to nodes...'
        scp ${swarm_fix} ${ssh_user}@${node_ip}:/tmp/
    done
}

# call if it was called directly
if [ $0 = "./scripts/swarm-fix-copy-script.sh" ]; then
    fix_swarm_route
fi
