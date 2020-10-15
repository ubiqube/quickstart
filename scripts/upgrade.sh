#!/bin/bash
set -e

PROG=$(basename $0)

target_version="2.2.0GA"
force_option=false
clean_option=false

upgrade(){
        echo "Starting upgrade"
        echo "----------------"

	docker-compose down
        
	sms_php_vol=$(docker volume ls | awk '{print $2}' | grep msa_sms_php)
        echo "Recreating Core Engine (msa_sms) volume $sms_php_vol"
        docker volume rm $sms_php_vol

	sms_devices_vol=$(docker volume ls | awk '{print $2}' | grep msa_sms_devices)
        echo "Recreating Core Engine (sms_devices) volume $sms_devices_vol"
        docker volume rm $sms_devices_vol

	dev_vol=$(docker volume ls | awk '{print $2}' | grep msa_dev)
        echo "Recreating Dev volume $dev_vol"
        docker volume rm $dev_vol

        docker-compose up -d --build

        docker-compose exec msa_dev /usr/bin/install_libraries.sh all --no-lic

        docker-compose restart msa_api
	
        docker-compose restart msa_sms

        msa_api=$(docker ps -q -f name=msa_api)
        echo "Starting crond on API container msa_api"
        docker exec -it -u root $msa_api crond
        echo "Done"

        echo "Upgrade done!"
}

cleanup(){
	echo "Cleaning unused images"
	echo "----------------------"
	docker image prune -f
}

usage() {
        echo "usage: $PROG [--force|-f]"
        echo "this script installs and upgrade a MSA"
        echo "-f: force the installation. This option will run the upgrade process without asking for user confirmation"
	echo "-c: cleanup unused images after upgrade to save disk space. This option clean all unused images, not only MSA quickstart ones "
        exit 0
}

main() {

	cmd=$1
	bis_cmd=$2
	case $cmd in
		"")
                  force_option=false
		  ;;		
                -f|--force)
                  force_option=true
		  ;;
		-c|--cleanup)
                  clean_option=true
		  ;;
		*)
                  echo "Error: unknown command: $1"
                  usage
		  ;;
	esac
	case $bis_cmd in
		"")
                 clean_option=false
		 ;;		
                -f|--force)
                  force_option=true
		  ;;		
                -c|--cleanup)
                  clean_option=true
		  ;;
		*)
                  echo "Error: unknown command: $2"
                  usage
		  ;;
	esac
	
	

        echo "Upgrading to last $target_version version"
        echo "################################"

	if [ ! -z "$(docker ps | grep msa)" ]; then
        	current_version=$(curl -s -k -XGET 'https://127.0.0.1/msa_version/' | grep -Po '(\d.\d.\w+)')
       		echo "You current MSA version is $current_version"
	fi

        if [ $force_option = false ] ; then

                if [[ $current_version =~ $target_version ]]
                then
                        echo "Already up to date: nothing to do"
                        exit
                fi

                while true; do
                        read -p "Are you sure to want to upgrade to $target_version? [y]/[N]" yn
                case $yn in
                        [Yy]* ) upgrade; break;;
                        [Nn]* ) exit;;
                        * ) echo "Please answer yes or no.";;
                esac
                done
        else
                upgrade;
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

main "$@"
