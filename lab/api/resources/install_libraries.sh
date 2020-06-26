#!/bin/bash
set -x

# update the github repositories
cd /opt/sms/bin/php ; 
### DA ###
if [ -d OpenMSA_Adapters ]; 
then 
    cd OpenMSA_Adapters; 
    #git checkout conf/models.properties; 
    git stash;
    git checkout master; 
    git pull origin master; 
else 
    git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; 
    cd OpenMSA_Adapters; 
    git checkout -b local_dev_branch_do_not_push;
fi ;
cd -; 
  	### MS ###
cd /opt/fmc_repository ; 
if [ -d OpenMSA_MS ]; 
then  
    cd OpenMSA_MS; 
    git stash;
    git checkout master; 
    git pull origin master; 
else 
    git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; 
    cd OpenMSA_MS; 
    git checkout -b local_dev_branch_do_not_push;
fi;
cd -; 
### WF ###
cd /opt/fmc_repository ; 
if [ -d OpenMSA_WF ]; 
then 
    cd OpenMSA_WF; 
    git checkout master; 
    git stash;
    git pull origin master; 
else 
    git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; 
    cd OpenMSA_MS; 
    git checkout -b local_dev_branch_do_not_push;
fi ; 
cd -; 
### Quickstart ###
cd /opt/fmc_repository ; 
if [ -d /opt/fmc_repository/quickstart ]; 
then 
    cd quickstart; 
    git stash;
    git checkout master; 
    git pull origin master;
else 
    git clone https://github.com/ubiqube/quickstart.git quickstart; 
fi ;
cd -; 


echo "install REST Generic Adapter from github repo"
cd /opt/sms/bin/php ; 
ln -fs OpenMSA_Adapters/adapters/rest_generic rest_generic; 
cd /opt/sms/templates/devices/; 
mkdir -p /opt/sms/templates/devices/rest_generic/conf; 
cd /opt/sms/templates/devices/rest_generic/conf; 
ln -fs /opt/sms/bin/php/rest_generic/conf/sms_router.conf sms_router.conf; 

echo "install Netconf Generic Adapter Adapter from github repo to add the netconf da bugfixes from Openmsa github"
cd /opt/sms/bin/php ; 
rm -rf netconf_generic;
ln -fs OpenMSA_Adapters/adapters/netconf_generic netconf_generic; 
cd /opt/sms/templates/devices/; 
mkdir -p /opt/sms/templates/devices/netconf_generic/conf; 
cd /opt/sms/templates/devices/netconf_generic/conf; 
rm -f sms_router.conf; 
ln -s /opt/sms/bin/php/netconf_generic/conf/sms_router.conf sms_router.conf; 

echo "install OneAccess Netconf Adapter from github repo to add the sms_router.conf file for the new model id for OneAccess-Netconf"
cd /opt/sms/bin/php ; 
rm -rf oneaccess_lbb;
ln -fs OpenMSA_Adapters/adapters/oneaccess_lbb oneaccess_lbb; 
cd /opt/sms/templates/devices/; 
mkdir -p /opt/sms/templates/devices/oneaccess_lbb/conf; 
cd /opt/sms/templates/devices/oneaccess_lbb/conf; 
rm -f sms_router.conf;
ln -s /opt/sms/bin/php/oneaccess_lbb/conf/sms_router.conf sms_router.conf; 

echo  "Configure properties files from openmsa github repo into custom folder"
cd /opt/ubi-jentreprise/resources/templates/conf/device/; 
mkdir -p /opt/ubi-jentreprise/resources/templates/conf/device/custom; 
#Using properties file from OpenMSA github for the custom versions
rm -f /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/conf/models.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;
rm -f /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;
cp /opt/sms/bin/php/OpenMSA_Adapters/conf/sdExtendedInfo.properties /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;
cp /opt/ubi-jentreprise/resources/templates/conf/device/manufacturers.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/; 
/opt/sms/bin/php/OpenMSA_Adapters/bin//da_installer install /opt/sms/bin/php/rest_generic; 


echo  "install some MS from OpenMSA github repo"
cd /opt/fmc_repository/CommandDefinition/; 
ln -s ../OpenMSA_MS/ADVA ADVA; ln -s ../OpenMSA_MS/.meta_ADVA .meta_ADVA; 
ln -s ../OpenMSA_MS/AWS AWS; ln -s ../OpenMSA_MS/.meta_AWS .meta_AWS; 
ln -s ../OpenMSA_MS/CISCO CISCO; ln -s ../OpenMSA_MS/.meta_CISCO .meta_CISCO; 
ln -s ../OpenMSA_MS/FORTINET FORTINET; ln -s ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; 
ln -s ../OpenMSA_MS/LINUX LINUX; ln -s ../OpenMSA_MS/.meta_LINUX .meta_LINUX; 
ln -s ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -s ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; 
ln -s ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -s ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; 
ln -s ../OpenMSA_MS/PALOALTO PALOALTO; ln -s ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; 
ln -s ../OpenMSA_MS/REST REST; ln -s ../OpenMSA_MS/.meta_REST .meta_REST; 

echo "install some WF from OpenMSA github repo"
cd /opt/fmc_repository/Process/; 
ln -fs ../OpenMSA_WF/Tutorials Tutorials ; 
ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; 

echo "Removing OneAccess Netconf MS defintions containing advanced variable types"
rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/Advanced /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/.meta_Advanced

/opt/ubi-jentreprise/configure; 
