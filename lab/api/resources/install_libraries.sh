#!/bin/bash
set -x

echo "-------------------------------------------------------------------------------"
echo " Update the github repositories "
echo "-------------------------------------------------------------------------------"
cd /opt/sms/bin/php ; 
echo " https://github.com/openmsa/Adapters.git "
### DA ###
if [ -d OpenMSA_Adapters ]; 
then 
    cd OpenMSA_Adapters; 
    #git checkout conf/models.properties; 
    git status;
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
echo " https://github.com/openmsa/Microservices.git "
cd /opt/fmc_repository ; 
if [ -d OpenMSA_MS ]; 
then  
    cd OpenMSA_MS; 
    git status;
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
echo " https://github.com/openmsa/Workflows.git "
cd /opt/fmc_repository ; 
if [ -d OpenMSA_WF ]; 
then 
    cd OpenMSA_WF; 
    git status;
    git stash;
    git checkout master; 
    git pull origin master; 
else 
    git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; 
    cd OpenMSA_MS; 
    git checkout -b local_dev_branch_do_not_push;
fi ; 
cd -; 
echo " Install the quickstart from https://github.com/ubiqube/quickstart.git"
cd /opt/fmc_repository ; 
if [ -d /opt/fmc_repository/quickstart ]; 
then 
    cd quickstart; 
    git status;
    git stash;
    git checkout master; 
    git pull origin master;
else 
    git clone https://github.com/ubiqube/quickstart.git quickstart; 
fi ;
cd -; 


echo "-------------------------------------------------------------------------------"
echo " Install REST Generic adapter source code from github repo"
echo "-------------------------------------------------------------------------------"
cd /opt/sms/bin/php ; 
rm -rf rest_generic;
ln -fs /opt/sms/bin/php//OpenMSA_Adapters/adapters/rest_generic rest_generic; 
cd /opt/sms/templates/devices/; 
rm -rf rest_generic;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/rest_generic rest_generic; 

echo "-------------------------------------------------------------------------------"
echo " Install ADVA NC adapter source code from github repo"
echo "-------------------------------------------------------------------------------"
cd /opt/sms/bin/php ; 
rm -rf adva_nc; 
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/adva_nc adva_nc; 
cd /opt/sms/templates/devices/; 
rm -rf adva_nc;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/adva_nc adva_nc; 

echo "-------------------------------------------------------------------------------"
echo " Install Netconf Generic adapter from github repo"
echo " Add the netconf da bugfixes from Openmsa github"
echo "-------------------------------------------------------------------------------"
cd /opt/sms/bin/php ; 
mv netconf_generic netconf_generic.bak;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/netconf_generic netconf_generic; 
cd /opt/sms/templates/devices/; 
mv netconf_generic netconf_generic.bak;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/netconf_generic netconf_generic; 

echo "-------------------------------------------------------------------------------"
echo " Install OneAccess Netconf Adapter from github repo " 
echo " Add the sms_router.conf file for the new model id for OneAccess-Netconf"
echo "-------------------------------------------------------------------------------"
cd /opt/sms/bin/php ; 
mv oneaccess_lbb oneaccess_lbb.bak;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/oneaccess_lbb oneaccess_lbb; 
cd /opt/sms/templates/devices/; 
mv oneaccess_lbb oneaccess_lbb.bak;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/oneaccess_lbb oneaccess_lbb; 

echo "-------------------------------------------------------------------------------"
echo " Configure properties files from openmsa github repo into custom folder"
echo "-------------------------------------------------------------------------------"
cd /opt/ubi-jentreprise/resources/templates/conf/device/; 
mkdir -p /opt/ubi-jentreprise/resources/templates/conf/device/custom; 
#Using properties file from OpenMSA github for the custom versions
rm -f /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;
ln -fs /opt/sms/bin/php/OpenMSA_Adapters/conf/models.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;
rm -f /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;
cp /opt/sms/bin/php/OpenMSA_Adapters/conf/sdExtendedInfo.properties /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;
cp /opt/ubi-jentreprise/resources/templates/conf/device/manufacturers.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/; 

echo "-------------------------------------------------------------------------------"
echo " Enable the adapters"
echo "-------------------------------------------------------------------------------"
/opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/rest_generic; 
/opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/adva_nc; 


echo "-------------------------------------------------------------------------------"
echo " Install some MS from OpenMSA github repo"
echo "-------------------------------------------------------------------------------"
cd /opt/fmc_repository/CommandDefinition/; 
ln -fs ../OpenMSA_MS/ADVA ADVA; ln -fs ../OpenMSA_MS/.meta_ADVA .meta_ADVA; 
ln -fs ../OpenMSA_MS/AWS AWS; ln -fs ../OpenMSA_MS/.meta_AWS .meta_AWS; 
ln -fs ../OpenMSA_MS/CISCO CISCO; ln -fs ../OpenMSA_MS/.meta_CISCO .meta_CISCO; 
ln -fs ../OpenMSA_MS/FORTINET FORTINET; ln -fs ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; 
ln -fs ../OpenMSA_MS/LINUX LINUX; ln -fs ../OpenMSA_MS/.meta_LINUX .meta_LINUX; 
ln -fs ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -fs ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; 
ln -fs ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -fs ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; 
ln -fs ../OpenMSA_MS/PALOALTO PALOALTO; ln -fs ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; 
ln -fs ../OpenMSA_MS/REST REST; ln -fs ../OpenMSA_MS/.meta_REST .meta_REST; 

echo "-------------------------------------------------------------------------------"
echo " Install some WF from OpenMSA github repo"
echo "-------------------------------------------------------------------------------"
cd /opt/fmc_repository/Process/; 
ln -fs ../OpenMSA_WF/Tutorials Tutorials ; 
ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; 

echo "-------------------------------------------------------------------------------"
echo " Removing OneAccess Netconf MS defintions containing advanced variable types"
echo "-------------------------------------------------------------------------------"
rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/Advanced /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/.meta_Advanced

chown -R ncuser:ncuser /opt/fmc_repository/*; \
chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
chown -R ncuser:ncuser /opt/sms/bin/php/*; \
chown -R ncuser:ncuser /opt/sms/templates/devices/; \
chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
 

/opt/ubi-jentreprise/configure; 
service wildfly restart; 
service wildfly status; 

/opt/sms/configure;
service ubi-sms status; 
