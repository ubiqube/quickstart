#!/bin/bash
set -e

PROG=$(basename $0)

target_version="2.8.5"
force_option=false
clean_option=false
remove_orphans=true
fresh_setup=false
ha_setup=false
mini_lab=false
ssh_user=root
mano=false

file_upgrade='.upgrade_unfinished'


install(){
    # mark that upgrade/installion is in progress
    touch ${file_upgrade}

    if [ $ha_setup = false ] ; then
        standaloneInstall
    else
        haInstall
    fi
}


standaloneInstall(){
    checkComposeVersion
    if [ $fresh_setup = false ] ; then
        if [ $remove_orphans = false ] ; then
            docker-compose down
        else
            docker-compose down --remove-orphans
        fi
    fi

    if [ $mano = false ] ; then
        docker-compose up -d --build
    else
        docker-compose -f docker-compose.yml -f lab/mano/docker-compose.mano.yml up -d --build
    fi

    docker-compose exec -T msa-dev rm -rf /opt/fmc_repository/Process/Reference

    docker-compose exec -T -w //usr/bin/ msa-dev bash -c  "./install_libraries.sh $(getLibOptions)"

    docker-compose restart msa-api
    docker-compose restart msa-sms
    docker-compose restart msa-alarm

    echo "Starting crond on API container msa-api"
    docker-compose exec -T -u root msa-api crond
    echo "Done"

    if [ $fresh_setup = false ] ; then
        echo "Remove AI ML database. Required on upgrades from 2.4"
        docker-compose exec -T -u root -w //usr/bin/ msa-ai-ml bash -c 'rm /msa_proj/database/db.sqlite3'
        docker-compose restart msa-ai-ml

        echo "Elasticsearch : .kibana_1 index regeneration"
        docker-compose exec -T -u root -w //home/install/scripts/ msa-es bash -c './kibana_index_update.sh'
        echo "Done"
    fi

    echo "Kibana configs & dashboard templates update"
    waitUpKibana 127.0.0.1
    docker-compose exec -T -u root -w //home/install/scripts msa-kibana bash -c 'php install_default_template_dash_and_visu.php'
    echo "Done"

    upgrade_done
}

haInstall(){

echo "############## Applying last images ##############################"
    ha_stack=$(docker stack ls --format '{{.Name}}'| grep 'ha\|msa' | head -n 1)
    if [ -z "$ha_stack" ]; then
        ha_stack="msa"
        echo "No stack found. Fresh HA installation"
    fi

    if [ $mano = false ] ; then
        docker stack deploy --with-registry-auth -c docker-compose.ha.yml $ha_stack
    else
        docker stack deploy --with-registry-auth -c docker-compose.ha.yml -c lab/mano/docker-compose.mano.ha.yml $ha_stack
    fi

    echo "############## Install OpenMSA Libraries ##############################"
    ha_dev_node_ip=$(getHaNodeIp msa-dev)
        ha_dev_container_ref=$(getHaContainerReference msa-dev)
        echo "DEV $ha_dev_ip $ha_dev_container_ref"
        echo "Checking SSH access to $ha_dev_node_run with user $ssh_user on IP $ha_dev_node_ip to install libraries. If failed, please set SSH key"
        ssh -tt "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec -it $ha_dev_container_ref /bin/bash -c '/usr/bin/install_libraries.sh $(getLibOptions)'"
        docker service update --force "$ha_stack"_msa-api
        docker service update --force "$ha_stack"_msa-sms
    docker service update --force "$ha_stack"_msa-alarm

        echo "############## Start CROND ############################################"
    ha_api_node_ip=$(getHaNodeIp msa-api)
        ha_api_container_ref=$(getHaContainerReference msa-api)
        #echo "API $ha_api_ip $ha_api_container_ref"
        #res=$(ssh -tt "-o BatchMode=Yes" $ssh_user@$ha_api_node_ip "docker exec -it -u root $ha_api_container_ref 'ps -edf | crond'")
        #echo "CROND started : $res"
        ssh -tt "-o BatchMode=Yes" $ssh_user@$ha_api_node_ip "docker exec -it -u root $ha_api_container_ref crond"

    if [ $fresh_setup = false ] ; then
        echo "################ Elasticsearch : .kibana_1 index regeneration #############"
        ha_es_node_ip=$(getHaNodeIp msa-es)
            ha_es_container_ref=$(getHaContainerReference msa-es)
            #echo "ES $ha_es_ip $ha_es_container_ref"
            ssh -tt $ssh_user@$ha_es_node_ip "docker exec -it -u root -w /home/install/scripts/ $ha_es_container_ref /bin/bash -c './kibana_index_update.sh'"
    fi

    echo "################ Kibana configs & dashboard templates update ##########"
        ha_kib_node_ip=$(getHaNodeIp msa-kib)
        ha_kib_container_ref=$(getHaContainerReference msa-kib)
        #echo "KIBANA $ha_kib_ip $ha_kib_container_ref"
    waitUpKibana $ha_kib_node_ip
        ssh -tt $ssh_user@$ha_kib_node_ip "docker exec -it -u root -w /home/install/scripts $ha_kib_container_ref /bin/bash -c 'php install_default_template_dash_and_visu.php'"

    fix_swarm_route

    upgrade_done
}

source ./scripts/swarm-fix-all-nodes.sh

upgrade_done(){
    echo "Upgrade done!"
    if [ -f "${file_upgrade}" ]; then
        # installation is sucessful, remove file
        rm "${file_upgrade}" > /dev/null
    fi
}

miniLabCreation(){
    if [ $ha_setup = false ] ; then
        docker-compose exec -T msa-dev /usr/bin/create_mini_lab.sh
    else
        ha_dev_node_ip=$(getHaNodeIp msa-dev)
            ha_dev_container_ref=$(getHaContainerReference msa-dev)
            ssh -tt "-o BatchMode=Yes" $ssh_user@$ha_dev_node_ip "docker exec -it $ha_dev_container_ref /usr/bin/create_mini_lab.sh"
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
    echo "-mano : apply mano containers"
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
            -mano|--mano)
                mano=true
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

    if [ ! -z "$(docker ps -a | grep msa)" ]; then
            if [ $ha_setup = true ]; then
            ha_front_ip=$(getHaNodeIp msa-front)
            current_version=$(curl -s -k -XGET "https://$ha_front_ip/msa_version/" | awk -F\" '{print $4}')
            echo "Your current MSA version is $current_version"
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
        if [[ $current_version =~ $target_version ]] && [ ! -f "${file_upgrade}" ]; then
                echo "Already up to date: nothing to do"
                exit
        fi

        while true; do
        action="upgrade to"
        if [ $fresh_setup = true ]; then
            action="install a new"
        fi

        if [[ $current_version =~ $target_version ]]; then
            echo "Looks like the installation has not finished properly"
            echo -n "Do you want to relaunch installtion? [y]/[N] "
            read yn
        else
            echo -n "Are you sure you want to $action $target_version? [y]/[N] "
            read yn
        fi
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

function checkComposeVersion(){
        compose_vers=$(docker-compose -v | grep -oP '\d+.\d+.\d+')
        if [ -z "$compose_vers" ]; then
                echo "No docker compose version found. Exit"
                exit
        fi
        # Remove point to compare an integer and keep 3 first numbers
        compose_vers_int="${compose_vers//.}"
        compose_vers_int="${compose_vers_int:0:3}"
        # echo found "$compose_vers_int"
        if [ "$compose_vers_int" -lt 129 ]; then
                echo "Your docker compose version $compose_vers is too old and must be upgraded to 1.28 to be used in $target_version"
                exit
        fi
}

main "$@"
