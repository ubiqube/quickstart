#!/bin/bash
docker stack  deploy --prune --with-registry-auth --resolve-image changed -c docker-compose.ha.yml -c docker-compose.kvdc_specific.yml -c lab/mano/docker-compose.mano.ha.yml msa 
./scripts/swarm-fix-all-nodes.sh
