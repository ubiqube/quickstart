#!/bin/bash
set -e

PROG=$(basename $0)

target_version="2.2.0GA"
force_option=false
clean_option=false
remove_orphans=false

upgrade(){
        echo "Starting upgrade"
        echo "----------------"

	if [ $remove_orphans = false ] ; then				  
		docker-compose down
	else
		docker-compose down --remove-orphans 
	fi
        
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

	if [ ! -z "$(docker volume ls | grep msa_dev)" ]; then
		dev_vol=$(docker volume ls | awk '{print $2}' | grep msa_dev)
        	echo "Recreating Dev volume $dev_vol"
        	docker volume rm $dev_vol
	fi

        docker-compose up -d --build

	docker-compose exec msa_dev rm -rf /opt/fmc_repository/Process/Reference

	if [ $force_option = false ] ; then
		docker-compose exec msa_dev /usr/bin/install_libraries.sh all --no-lic
	else
		docker-compose exec msa_dev /usr/bin/install_libraries.sh all --no-lic -y
	fi
	
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
	echo "usage: $PROG [--force|-f] [--cleanup|-c] [--remove-orphans|-ro]"
	echo "this script installs and upgrade a MSA"
	echo "-f: force the upgrade without asking for user confirmation. Permit also to reapply the upgrade and to auto merge files from OpenMSA"
	echo "-c: cleanup unused images after upgrade to save disk space. This option clean all unused images, not only MSA quickstart ones"
	echo "-ro: remove containers for services not defined in the compose file. Use it if some containers use same network as MSA"
        exit 0
}

main() {

	for arg
	do
    	case "$arg" in
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

        echo "Upgrading to last $target_version version"
        echo "################################"

        if [ $force_option = false ] ; then

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
