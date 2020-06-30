#!/bin/bash
set -x


update_github_repo() {

    echo "-------------------------------------------------------------------------------"
    echo " Update the github repositories "
    echo "-------------------------------------------------------------------------------"
    cd /opt/sms/bin/php ; 
    echo " https://github.com/openmsa/Adapters.git "
    ### DA ###
    if [ -d OpenMSA_Adapters ]; 
    then 
        cd OpenMSA_Adapters; 
        git stash;
        git checkout master;
        git pull;
        git stash pop;
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
        git stash;
        git checkout master;
        git pull;
        git stash pop;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ### TODO REMOVE BEFORE PR MERGE
        git checkout openmsa_lib_packaging;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull;
    else 
        git clone https://github.com/ubiqube/quickstart.git quickstart; 
    fi ;

}
#
# $1 : adapter folder name as in /opt/sms/bin/php
# $2 : installation mode: DEV_MODE = create symlink / USER_MODE = copy code
#
install_adapter() {
    echo "-------------------------------------------------------------------------------"
    echo " Install $1 adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"

    cd /opt/sms/bin/php ; 
    [[ -d $1 ]] && rm -rf $1;
    [[ $2 = DEV_MODE ]] &&  ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1 $1; 
    [[ $2 = USER_MODE ]] &&  cp -r /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1 .; 
    chown -R ncuser.ncuser /opt/sms/bin/php/$1;
    
    cd /opt/sms/templates/devices/; 
    [[ -d $1 ]] && rm -rf $1;
    [[ $2 = DEV_MODE ]] &&  ln -fs /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1 $1; 
    [[ $2 = USER_MODE ]] &&  cp -r /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1 .; 

    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1; 

}

install_microservices () {
    
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
}

install_workflows() {
    echo "-------------------------------------------------------------------------------"
    echo " Install some WF from OpenMSA github repo"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Process/; 
    ln -fs ../OpenMSA_WF/Tutorials Tutorials ; 
    ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; 
}

update_github_repo

install_adapter linux_generic USER_MODE;
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

install_microservices;
install_workflows;


echo "-------------------------------------------------------------------------------"
echo " Removing OneAccess Netconf MS defintions containing advanced variable types"
echo "-------------------------------------------------------------------------------"
rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/Advanced /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/.meta_Advanced

chown -R ncuser:ncuser /opt/fmc_repository/*; \
chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
chown -R ncuser:ncuser /opt/sms/bin/php/*; \
chown -R ncuser:ncuser /opt/sms/templates/devices/; \
chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
 

/opt/ubi-jentreprise/configure >> install.log  2>&1; 
service wildfly restart  >> install.log  2>&1; 
/opt/ses/configure >> install.log  2>&1; 
service tomcat restart >> install.log  2>&1; 
/opt/sms/configure >> install.log  2>&1; ;

service ubi-sms status; 
service wildfly status; 

