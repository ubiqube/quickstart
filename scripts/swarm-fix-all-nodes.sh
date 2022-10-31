#!/bin/bash

set -e

# set only if it was called directly
if [ $0 = "./scripts/swarm-fix-all-nodes.sh" ]; then
    ssh_user=$USER
fi

fix_swarm_route() {
    swarm_fix='./scripts/swarm-fix-route.sh'
    swarm_fix_manager='./scripts/swarm-fix-route_manager.sh'

    for node  in $(docker node ls -q  -f  node.label=worker=app); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')
	node_name=$(docker node inspect ${node} --format '{{ .Description.Hostname }}')

        echo "Copying swarm-fix-route file to nodes...$node_name"
        scp ${swarm_fix} ${ssh_user}@${node_ip}:/tmp/
#        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -d"
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -a"
    done
    for node  in $(docker node ls -q  -f  node.label=worker=sms); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')
        node_name=$(docker node inspect ${node} --format '{{ .Description.Hostname }}')

        echo "Copying swarm-fix-route file to nodes...$node_name"
        scp ${swarm_fix} ${ssh_user}@${node_ip}:/tmp/
#        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -d"
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -a"
    done
    for node  in $(docker node ls -q  -f  node.label=worker=mano); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')
        node_name=$(docker node inspect ${node} --format '{{ .Description.Hostname }}')

        echo "Copying swarm-fix-route file to nodes...$node_name"
        scp ${swarm_fix} ${ssh_user}@${node_ip}:/tmp/
#        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -d"
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route.sh -a"
    done    
    for node  in $(docker node ls -q  -f  node.label=manager); do
        node_ip=$(docker node inspect ${node} --format '{{ .Status.Addr }}')
	node_name=$(docker node inspect ${node} --format '{{ .Description.Hostname }}')

        echo "Copying swarm-fix-route file to nodes...$node_name"
        scp ${swarm_fix_manager} ${ssh_user}@${node_ip}:/tmp/
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route_manager.sh -d"	
        ssh -tt "-o BatchMode=Yes" ${ssh_user}@${node_ip} "bash /tmp/swarm-fix-route_manager.sh -a"
    done
}

# call if it was called directly
if [ $0 = "./scripts/swarm-fix-all-nodes.sh" ]; then
    fix_swarm_route
fi
