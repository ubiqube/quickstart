#!/bin/bash
set -e

target_version="2.2.0GA"

echo "Upgrading to last $target_version version"
echo "################################"

current_version=$(git status | grep 'On branch')
echo "You current version is $current_version"

if [[ $current_version =~ $target_version ]]
then
        echo "Nothing to do"
        exit
fi


upgrade(){
        echo "Upgrade running"
        echo "#############"

        docker-compose down

        sms_php_vol=$(docker volume ls | awk '{print $2}' | grep msa_sms_php)
        echo "Recreate SMS volume $sms_php_vol for [MSA-8682]"
        docker volume rm $sms_php_vol

        # Need to call here script to clean old images [MSA-8583]

        docker-compose up -d

        docker-compose exec msa_dev /usr/bin/install_libraries.sh

        docker-compose restart msa_api

        docker-compose restart msa_sms

        msa_api=$(docker ps -q -f name=msa_api)
        echo "Start crond on API container for [MSA-8387]"
        docker exec -it -u root $msa_api crond

        echo "Upgrade done!"
}

while true; do
    read -p "Are you sure to want to upgrade to $target_version?" yn
    case $yn in
        [Yy]* ) upgrade; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
