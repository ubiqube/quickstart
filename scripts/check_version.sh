#!/bin/bash

#set -x

if docker node ls >/dev/null 2>&1; 
then
   swarm_mode=true
fi
echo


git_status()
{
        echo "git status"
}

git_branch()
{
        echo "git branch --show-current"
}

git_log()
{
        echo "git log --no-color --oneline -2"
}

if $swarm_mode;
then
	msa_dev_runner_node=$(docker service ps msa_msa-dev --format '{{.Node}}'| head -n 1)
	db_runner_node=$(docker service ps msa_db --format '{{.Node}}'| head -n 1)
fi

echo '################################'  $(hostname)  '###############################################'

echo "#Docker/Swarm config (Quickstart)#"
 $(git_branch)
 $(git_log)
echo


echo "#Running images#"
if [ "$swarm_mode" = true ] 
then
	docker service ls --format {{.Image}}
else
	docker ps --format {{.Image}}
fi
echo


echo "#Generic Devices Adaptors (OpenMSA_Adapter)#"
if [ "$swarm_mode" = true ] 
then
	ssh $msa_dev_runner_node  'docker exec $(docker ps -qf name=msa-dev) bash -c "cd /opt/devops/OpenMSA_Adapters/;'$(git_branch)';'$(git_log)'"'
else
	docker exec $(docker ps -qf name=msa.dev) bash -c "cd /opt/devops/OpenMSA_Adapters/;$(git_branch);$(git_log)"
fi
echo


echo "#MSA config-vars# "
if [ "$swarm_mode" = true ] 
then
	ssh $db_runner_node 'echo -e "\pset tuples_only\nselect m.var_name, m.var_value from redone.msa_vars m inner join (select var_name, max(var_lastupdated) var_lastupdated from redone.msa_vars group by var_name) mv on m.var_name = mv.var_name and m.var_lastupdated = mv.var_lastupdated;" > query_msa_vars'
 	ssh $db_runner_node 'docker cp query_msa_vars $(docker ps -qf name=db.1):/tmp/query_msa_vars'
 	ssh $db_runner_node 'docker exec $(docker ps -qf name=db.1) bash -c  "cat /tmp/query_msa_vars  | psql -h /tmp/ -d POSTGRESQL"' |grep -v "Tuples only is on"
else
	echo -e "\pset tuples_only\nselect m.var_name, m.var_value from redone.msa_vars m inner join (select var_name, max(var_lastupdated) var_lastupdated from redone.msa_vars group by var_name) mv on m.var_name = mv.var_name and m.var_lastupdated = mv.var_lastupdated;" > query_msa_vars
	docker cp query_msa_vars $(docker ps -qf name=db):/tmp/query_msa_vars
	docker exec $(docker ps -qf name=db) bash -c  "cat /tmp/query_msa_vars  | psql -h /tmp/ -d POSTGRESQL" |grep -v "Tuples only is on"
fi
echo

echo '##################################################################################################'


