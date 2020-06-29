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
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout openmsa_lib_packaging;
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   git pull;
else 
    git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; 
    cd OpenMSA_Adapters; 
fi ;
cd -; 
  	### MS ###
echo " https://github.com/openmsa/Microservices.git "
cd /opt/fmc_repository ; 
if [ -d OpenMSA_MS ]; 
then  
    cd OpenMSA_MS; 
    git pull; 
else 
    git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; 
    cd OpenMSA_MS; 
fi;
cd -; 
### WF ###
echo " https://github.com/openmsa/Workflows.git "
cd /opt/fmc_repository ; 
if [ -d OpenMSA_WF ]; 
then 
    cd OpenMSA_WF; 
    git pull; 
else 
    git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; 
    cd OpenMSA_MS; 
fi ; 
cd -; 
echo " Install the quickstart from https://github.com/ubiqube/quickstart.git"
cd /opt/fmc_repository ; 
if [ -d /opt/fmc_repository/quickstart ]; 
then 
    cd quickstart; 
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout openmsa_lib_packaging;
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    git pull;
else 
    git clone https://github.com/ubiqube/quickstart.git quickstart; 
fi ;

install_adapter() {
    echo "-------------------------------------------------------------------------------"
    echo " Install $0 adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"

    cd /opt/sms/bin/php ; 
    [[ -d linux_generic ]] && rm -rf $0;
    ln -fs /opt/sms/bin/php//OpenMSA_Adapters/adapters/$0 $0; 
    cd /opt/sms/templates/devices/; 
    [[ -d $0 ]] && rm -rf $0;
    ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/$0 $0; 

    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/$0; 

}


install_adapter linux_generic;

#install_adapter("rest_generic");
#install_adapter("aws_generic");
#install_adapter("stormshield");
#install_adapter("adva_nc");
#install_adapter("f5_bigip");
#install_adapter("a10_thunder");
#install_adapter("virtuora_nc");
#install_adapter("oneaccess_netconf");
#install_adapter("oneaccess_lbb");
#install_adapter("oneaccess_whitebox");



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
