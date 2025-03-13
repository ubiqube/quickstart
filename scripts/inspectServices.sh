#!/bin/bash
TMP_FILE=/tmp/cmd.$$.txt
cat > $TMP_FILE << 'EOF'
  for i in $(docker ps --format '{{.ID}}'); do docker inspect $i --format '{{printf "%-32s" (index .Config.Labels "com.docker.swarm.service.name")}} {{printf "%-40s" .NetworkSettings.SandboxKey}} {{range .NetworkSettings.Networks}}{{printf "%-20s" .IPAMConfig.IPv4Address}}{{end}}'; done
EOF
for node in $(docker node ls --format '{{.Hostname}}'); do
  echo "#################### $node #######################"
  ssh $node 'bash -s' < $TMP_FILE
done
rm $TMP_FILE
