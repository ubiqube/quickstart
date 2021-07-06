#!/bin/bash
set -e

PROG=$(basename $0)

target_version="2.5.0GA"
force_option=false
clean_option=false
remove_orphans=false
fresh_setup=false
ha_setup=false
mini_lab=false
ssh_user=root


install(){
	if [ $ha_setup = false ] ; then				  
		standaloneInstall
	else
		haInstall
	fi
}


standaloneInstall(){
	if [ $fresh_setup = false ] ; then
		if [ $remove_orphans = false ] ; then				  
			docker-compose down
		else
			docker-compose down --remove-orphans 
		fi
		
		############ For 2.2 upgrade
		if [ ! -z "$(docker volume ls | grep msa_sms_php)" ]; then
			sms_php_vol=$(docker volume ls | awk '{print $2}' | grep msa_sms_php)
		echo "Recreating Core Engine (msa_sms) volume $sms_php_vol"
		docker volume rm $sms_php_vol
		fi

		if [ ! -z "$(docker volume ls | grep msa_sms_devices)" ]; then
			sms_devices_vol=$(docker volume ls | awk '{print $2}' | grep msa_sms_devices)
		echo "Recreating Core Engine (sms_devices) volume $sms_devices_vol"
		docker volume rm $sms_devices_vol
		fi
	fi	

    	docker-compose up -d --build

	docker-compose exec -T msa_dev rm -rf /opt/fmc_repository/Process/Reference

	docker-compose exec -T msa_dev /usr/bin/install_libraries.sh $(getLibOptions)

    	docker-compose restart msa_api
    	docker-compose restart msa_sms
	docker-compose restart msa_alarm
	
	echo "Starting crond on API container msa_api"
	docker-compose exec -T -u root msa_api crond
	echo "Done"
    
    	if [ $fresh_setup = false ] ; then
		############ For 2.3 upgrade
		echo "Migrating old BPMs from DataFile to BPM repository"
		docker-compose exec -T msa_dev /usr/bin/migrate_bpmn.sh -r

		echo "Removing old instances of topology"
		docker-compose exec -T msa_dev /usr/bin/clean_old_topology_instances.sh
	fi

	echo "Elasticsearch : .kibana_1 index regeneration"
	docker-compose exec -T -u root -w /home/install/scripts/ msa_es bash -c './kibana_index_update.sh'
	echo "Done"

	echo "Kibana configs & dashboard templates update"
	waitUpKibana 127.0.0.1
	docker-compose exec -T -u root -w /home/install/scripts msa_kibana bash -c 'php install_default_template_dash_and_visu.php'
	echo "Done"

	echo "Upgrade done!"
}

haInstall(){

	echo "############## Applying last images ##############################"
	ha_stack=$(docker stack ls --format '{{.Name}}'| head -n 1)
	if [ -z "$ha_stack" ]; then
		ha_stack="ha"
		echo "No stack found. Fresh HA installation"
	fi
	docker stack deploy --with-registry-auth -c docker-compose.simple.ha.yml $ha_stack
	
	echo "############## Install OpenMSA Libraries ##############################"
	ha_dev_node_ip=$(getHaNodeIp msa_dev)
        ha_dev_container_ref=$(getHaContainerReference msa_dev)
        echo "DEV $ha_dev_ip $ha_dev_container_ref"
        echo "Checking SSH access to $ha_dev_node_run with user $ssh_user on IP $ha_dev_node_ip to install libraries. If failed, please set SSH key"
        ssh "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec $ha_dev_container_ref /bin/bash -c '/usr/bin/install_libraries.sh $(getLibOptions)'"
        docker service update --force "$ha_stack"_msa_api
        docker service update --force "$ha_stack"_msa_sms
	docker service update --force "$ha_stack"_msa_alarm

        echo "############## Start CROND ############################################"
	ha_api_node_ip=$(getHaNodeIp msa_api)
        ha_api_container_ref=$(getHaContainerReference msa_api)
        #echo "API $ha_api_ip $ha_api_container_ref"
        #res=$(ssh "-o BatchMode=Yes" $ssh_user@$ha_api_node_ip "docker exec -u root $ha_api_container_ref 'ps -edf | crond'")
        #echo "CROND started : $res"
        ssh "-o BatchMode=Yes" $ssh_user@$ha_api_node_ip "docker exec -u root $ha_api_container_ref crond"

	if [ $fresh_setup = false ] ; then
		echo "############### Migrating old BPMs from DataFile to BPM repository ####"
		ssh "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec $ha_dev_container_ref /bin/bash -c '/usr/bin/migrate_bpmn.sh -r'"

		#echo "############### Removing old instances of topology ####################"
		#ssh "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec $ha_dev_container_ref /bin/bash -c '/usr/bin/clean_old_topology_instances.sh'"
	fi

	echo "################ Elasticsearch : .kibana_1 index regeneration #############"
	ha_es_node_ip=$(getHaNodeIp msa_es)
        ha_es_container_ref=$(getHaContainerReference msa_es)
        #echo "ES $ha_es_ip $ha_es_container_ref"
        ssh $ssh_user@$ha_es_node_ip "docker exec -u root -w /home/install/scripts/ $ha_es_container_ref /bin/bash -c './kibana_index_update.sh'"

	echo "################ Kibana configs & dashboard templates update ##########"
        ha_kib_node_ip=$(getHaNodeIp msa_kib)
        ha_kib_container_ref=$(getHaContainerReference msa_kib)
        #echo "KIBANA $ha_kib_ip $ha_kib_container_ref"
	waitUpKibana $ha_kib_node_ip
        ssh $ssh_user@$ha_kib_node_ip "docker exec -u root -w /home/install/ $ha_kib_container_ref /bin/bash -c 'php install_default_template_dash_and_visu.php'"

	echo "Upgrade done!"
}

miniLabCreation(){
	if [ $ha_setup = false ] ; then				  
		docker-compose exec -T msa_dev /usr/bin/create_mini_lab.sh
	else
		ha_dev_node_ip=$(getHaNodeIp msa_dev)
        	ha_dev_container_ref=$(getHaContainerReference msa_dev)
	        ssh "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec $ha_dev_container_ref /usr/bin/create_mini_lab.sh"
	fi
}

cleanup(){
	echo "Cleaning unused images"
	echo "----------------------"
	docker image prune -f
}

usage() {
	echo "usage: $PROG [--mini-lab|-m] [--force|-f] [--cleanup|-c] [--remove-orphans|-ro]"
	echo "this script installs and upgrades a MSA"
	echo "-m: mini lab creation. Create a demo platform around a Linux ME"
	echo "-f: force the upgrade without asking for user confirmation. Permit also to reapply the upgrade and to auto merge files from OpenMSA"
	echo "-c: cleanup unused images after upgrade to save disk space. This option clean all unused images, not only MSA quickstart ones"
	echo "-ro: remove containers for services not defined in the compose file. Use it if some containers use same network as MSA"
        exit 0
}

main() {

	for arg
	do
    	case "$arg" in
		-m|--mini-lab)
                mini_lab=true
                ;;
         	-f|--force)
                force_option=true
                ;;
        	-c|--cleanup)
                clean_option=true
                ;;
        	-ro|--remove-orphans)
            	remove_orphans=true
                ;;
        	?|--help)
                usage
                ;;
        	*)
            	echo "Unknown arguments"
           		usage
            	;;
     		esac
	done

	is_ha=$(docker stack ls > /dev/null 2>&1 ; echo $?)
	if [ $is_ha -eq 0 ]; then
		ha_setup=true
		echo "HA setup detected"
	fi

	if [ ! -z "$(docker ps | grep msa)" ]; then
        	if [ $ha_setup = true ]; then
			ha_front_ip=$(getHaNodeIp msa_front)
			current_version=$(curl -s -k -XGET "https://$ha_front_ip/msa_version/" | awk -F\" '{print $4}')
			echo "You current MSA version is $current_version"
			echo "#####################################################"
		else
			current_version=$(curl -s -k -XGET 'https://127.0.0.1/msa_version/' | awk -F\" '{print $4}')
			echo "You current MSA version is $current_version"
			echo "#####################################################"
		fi
  	 else
                fresh_setup=true
                echo "Installing a new $target_version"
                echo "################################"
   	fi


    	if [ $force_option = false ] ; then    
		if [[ $current_version =~ $target_version ]]; then
            		echo "Already up to date: nothing to do"
        	exit
		fi
    
        while true; do
	    action="upgrade to"
	    if [ $fresh_setup = true ]; then
		action="install a new"
	    fi

            read -p "Are you sure you want to $action $target_version? [y]/[N]" yn
    	    case $yn in
                [Yy]* ) install; break;;
                [Nn]* ) exit;;
            	* ) echo "Please answer yes or no.";;
            esac
        done
    else
        install;
    fi

	if [ "$mini_lab" = true ] ; then
        	miniLabCreation
    	fi

	if [ "$clean_option" = true ] ; then
		if [ $force_option = false ] ; then
			while true; do
                read -p "Are you sure to want to clean unused images? [y]/[N]" yn
				case $yn in
                	[Yy]* ) cleanup; break;;
					[Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
				esac
			done
        else
			cleanup;
		fi
    fi
}

function getHaNodeIp(){
	ha_sv_name=$(docker service ls --format '{{.Name}}' | grep $1)
    	ha_node_run=$(docker service ps $ha_sv_name --format "{{.Node}}" -f "desired-state=running" | head -n 1)
	ha_node_ip=$(docker node inspect $ha_node_run --format '{{ .Status.Addr  }}')
	echo $ha_node_ip
}

function getHaContainerReference(){
    	ha_sv_name=$(docker service ls --format '{{.Name}}' | grep $1)
	ha_container_ref=$(docker service ps --no-trunc $ha_sv_name --format "{{.Name}}.{{.ID}}" -f "desired-state=running" | head -n 1)
	echo $ha_container_ref
}

function getLibOptions(){
	lib_options="all"
	if [ $force_option = true ] || [ $fresh_setup = true ] ; then
		lib_options+=" -y"
	fi
	echo $lib_options
}

function waitUpKibana(){
	echo "Wait Kibana to be ready"
        until [ $(curl -s -o /dev/null -L -w ''%{http_code}'' "http://$1:5601/kibana") == "200" ]
	do
		printf '.'
		sleep 3
	done
}

main "$@"
