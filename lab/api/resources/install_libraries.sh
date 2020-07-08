#!/bin/bash
#set -x

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
        #git checkout config_remaining_adapters;
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
        #git checkout config_remaining_adapters;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull;
    else 
        git clone https://github.com/ubiqube/quickstart.git quickstart; 
    fi ;

}

uninstall_adapter() {
    echo "-------------------------------------------------------------------------------"
    echo " Uninstall $1 adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"
    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer uninstall /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1
}

#
# $1 : adapter folder name as in /opt/sms/bin/php
# $2 : installation mode: DEV_MODE = create symlink / USER_MODE = copy code
#
install_adapter() {
    echo "-------------------------------------------------------------------------------"
    echo " Install $1 adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"

    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/OpenMSA_Adapters/adapters/$1 $2
    echo "DONE"

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
    ln -fs ../OpenMSA_MS/REDFISHAPI REDFISHAPI; ln -fs ../OpenMSA_MS/.meta_REDFISHAPI .meta_REDFISHAPI; 
    echo "DONE"

}

install_workflows() {
    echo "-------------------------------------------------------------------------------"
    echo " Install some WF from OpenMSA github repo"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Process/; 
    ln -fs ../OpenMSA_WF/BIOS_Automation BIOS_Automation
    ln -fs ../OpenMSA_WF/.meta_BIOS_Automation .meta_BIOS_Automation
    echo "DONE"

}

update_github_repo

#uninstall_adapter netasq




install_adapter linux_generic 
install_adapter pfsense_fw
install_adapter checkpoint_r80
install_adapter rest_generic 
install_adapter aws_generic  
install_adapter adva_nc 
install_adapter f5_bigip 
install_adapter virtuora_nc 
install_adapter catalyst_ios 
install_adapter cisco_apic  
install_adapter cisco_nexus9000
install_adapter cisco_isr
install_adapter cisco_asr
install_adapter cisco_asa_generic
install_adapter esa
install_adapter wsa 
install_adapter rancher_cmp
install_adapter hp5900
install_adapter hp2530
install_adapter nec_ix
install_adapter nec_nfa
install_adapter oneaccess_lbb 
install_adapter oneaccess_whitebox
install_adapter oneaccess_netconf
install_adapter fortigate
install_adapter fortiwaf
install_adapter fortinet_fortimanager
install_adapter fortinet_fortianalyzer
install_adapter fortinet_jsonapi
install_adapter paloalto_chassis
install_adapter paloalto_generic
install_adapter paloalto_vsys
install_adapter netconf_generic
install_adapter juniper_srx
install_adapter redfish_generic
install_adapter veex_rtu
install_adapter vmware_vsphere
install_adapter mon_cisco_ios
install_adapter mon_cisco_asa
install_adapter mon_generic
install_adapter mon_checkpoint_fw
install_adapter mon_fortinet_fortigate

install_adapter kubernetes_generic
install_adapter nfvo_generic
install_adapter vnfm_generic

#install_adapter stormshield 
#install_adapter a10_thunder 

install_microservices;
install_workflows;


echo "-------------------------------------------------------------------------------"
echo " Removing OneAccess Netconf MS definition with advanced variable types"
echo "-------------------------------------------------------------------------------"
rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/Advanced 
rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/.meta_Advanced
echo "DONE"

echo "-------------------------------------------------------------------------------"
echo " update file owner to ncuser.ncuser"
echo "-------------------------------------------------------------------------------"
chown -R ncuser:ncuser /opt/fmc_repository/*; \
chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
chown -R ncuser:ncuser /opt/sms/bin/php/*; \
chown -R ncuser:ncuser /opt/sms/templates/devices/; \
#chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
echo "DONE"

echo "-------------------------------------------------------------------------------"
echo " service restart"
echo "-------------------------------------------------------------------------------"
/opt/ubi-jentreprise/configure >> /var/log/quickstart_install.log  2>&1; 
service wildfly restart  >> /var/log/quickstart_install.log  2>&1; 
#/opt/ses/configure >> /var/log/quickstart_install.log  2>&1; 
#service tomcat restart >> /var/log/quickstart_install.log  2>&1; 
#/opt/sms/configure >> /var/log/quickstart_install.log  2>&1;
sleep 4
service ubi-sms status; 
service wildfly status; 
echo "DONE"

