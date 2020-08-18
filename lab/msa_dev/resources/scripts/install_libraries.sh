#!/bin/bash
#set -x

PROG=$(basename $0)

update_github_repo() {

    echo "-------------------------------------------------------------------------------"
    echo " Update the github repositories "
    echo "-------------------------------------------------------------------------------"
    cd /opt/devops ; 
    echo "  >> https://github.com/openmsa/Adapters.git "
    if [ -d OpenMSA_Adapters ]; 
    then 
        cd OpenMSA_Adapters; 
        git stash;
        git checkout master;
        git pull;
        git stash pop;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ### TODO REMOVE BEFORE PR MERGE
        #git checkout 2.1.0GA;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull;
    else 
        git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; 
        cd OpenMSA_Adapters; 
    fi ;
    cd -; 
        ### MS ###
    echo "  >> https://github.com/openmsa/Microservices.git "
    cd /opt/fmc_repository ; 
    if [ -d OpenMSA_MS ]; 
    then  
        cd OpenMSA_MS; 
        git stash;
        git checkout master;
        git pull;
        git stash pop;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ### TODO REMOVE BEFORE PR MERGE
        #git checkout 2.1.0GA;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull;
    else 
        git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; 
        cd OpenMSA_MS; 
    fi;
    cd -; 
    ### WF ###
    echo "  >> https://github.com/openmsa/Workflows.git "
    cd /opt/fmc_repository ; 
    if [ -d OpenMSA_WF ]; 
    then 
        cd OpenMSA_WF;
	      git stash;
        git checkout master;
        git pull;
        git stash pop;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ### TODO REMOVE BEFORE PR MERGE
        #git checkout 2.1.0GA;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull; 
    else 
        git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; 
        cd OpenMSA_WF;
    fi ; 
    cd -; 
    ### Etsi-Mano ###
    echo "  >> https://github.com/openmsa/etsi-mano.git "
    cd /opt/fmc_repository ; 
    if [ -d OpenMSA_MANO ]; 
    then 
        cd OpenMSA_MANO; 
        git pull; 
    else 
        git clone https://github.com/openmsa/etsi-mano.git OpenMSA_MANO; 
        cd OpenMSA_MANO; 
    fi ; 
    cd -; 
    echo "  >> Install the quickstart from https://github.com/ubiqube/quickstart.git"
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
        #git checkout 2.1.0GA;
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        git pull;
    else 
        git clone https://github.com/ubiqube/quickstart.git quickstart; 
    fi ;

}

uninstall_adapter() {
    DEVICE_DIR=$1
    echo "-------------------------------------------------------------------------------"
    echo " Uninstall $DEVICE_DIR adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"
    /opt/devops/OpenMSA_Adapters/bin/da_installer uninstall /opt/devops/OpenMSA_Adapters/adapters/$DEVICE_DIR
}

#
# $1 : adapter folder name as in /opt/sms/bin/php
# $2 : installation mode: DEV_MODE = create symlink / USER_MODE = copy code
#
install_adapter() {
    DEVICE_DIR=$1
    MODE=$2
    echo "-------------------------------------------------------------------------------"
    echo " Install $DEVICE_DIR adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"

    /opt/devops/OpenMSA_Adapters/bin/da_installer install /opt/devops/OpenMSA_Adapters/adapters/$DEVICE_DIR $MODE
    echo "DONE"

}

install_microservices () {
    
    echo "-------------------------------------------------------------------------------"
    echo " Install some MS from OpenMSA github repo"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/CommandDefinition/; 
    echo "  >> ADVA"
    ln -fs ../OpenMSA_MS/ADVA ADVA; ln -fs ../OpenMSA_MS/.meta_ADVA .meta_ADVA; 
    echo "  >> ANSIBLE"
    ln -fs ../OpenMSA_MS/ANSIBLE ANSIBLE; ln -fs ../OpenMSA_MS/.meta_ANSIBLE .meta_ANSIBLE; 
    echo "  >> AWS"
    ln -fs ../OpenMSA_MS/AWS AWS; ln -fs ../OpenMSA_MS/.meta_AWS .meta_AWS; 
    echo "  >> CHECKPOINT"
    ln -fs ../OpenMSA_MS/CHECKPOINT CHECKPOINT; ln -fs ../OpenMSA_MS/.meta_CHECKPOINT .meta_CHECKPOINT; 
    echo "  >> CISCO"
    ln -fs ../OpenMSA_MS/CISCO CISCO; ln -fs ../OpenMSA_MS/.meta_CISCO .meta_CISCO; 
    echo "  >> CITRIX"
    ln -fs ../OpenMSA_MS/CITRIX CITRIX; ln -fs ../OpenMSA_MS/.meta_CITRIX .meta_CITRIX; 
    echo "  >> FLEXIWAN"
    ln -fs ../OpenMSA_MS/FLEXIWAN FLEXIWAN; ln -fs ../OpenMSA_MS/.meta_FLEXIWAN .meta_FLEXIWAN; 
    echo "  >> FORTINET"
    ln -fs ../OpenMSA_MS/FORTINET FORTINET; ln -fs ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; 
    #echo "  >> JUNIPER"
    #ln -fs ../OpenMSA_MS/JUNIPER JUNIPER; ln -fs ../OpenMSA_MS/.meta_JUNIPER .meta_JUNIPER;
    #rm -rf  JUNIPER/SSG
    echo "  >> LINUX"
    ln -fs ../OpenMSA_MS/LINUX LINUX; ln -fs ../OpenMSA_MS/.meta_LINUX .meta_LINUX; 
    echo "  >> MIKROTIK"
    ln -fs ../OpenMSA_MS/MIKROTIK MIKROTIK; ln -fs ../OpenMSA_MS/.meta_MIKROTIK .meta_MIKROTIK; 
    echo "  >> OPENSTACK"
    ln -fs ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -fs ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; 
    echo "  >> ONEACCESS"
    ln -fs ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -fs ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; 
    echo "  >> PALOALTO"
    ln -fs ../OpenMSA_MS/PALOALTO PALOALTO; ln -fs ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; 
    echo "  >> PFSENSE"
    ln -fs ../OpenMSA_MS/PFSENSE PFSENSE; ln -fs ../OpenMSA_MS/.meta_PFSENSE .meta_PFSENSE; 
    echo "  >> REDFISHAPI"
    ln -fs ../OpenMSA_MS/REDFISHAPI REDFISHAPI; ln -fs ../OpenMSA_MS/.meta_REDFISHAPI .meta_REDFISHAPI; 
    echo "  >> REST"
    ln -fs ../OpenMSA_MS/REST REST; ln -fs ../OpenMSA_MS/.meta_REST .meta_REST; 
    echo "  >> ETSI-MANO"
    ln -fs ../OpenMSA_MS/NFVO NFVO;  ln -fs ../OpenMSA_MS/.meta_NFVO .meta_NFVO
    ln -fs ../OpenMSA_MS/VNFM VNFM; ln -fs ../OpenMSA_MS/.meta_VNFM .meta_VNFM
    ln -fs ../OpenMSA_MS/KUBERNETES KUBERNETES; ln -fs ../OpenMSA_MS/.meta_KUBERNETES .meta_KUBERNETES
 
    echo "DONE"

}

install_workflows() {
    echo "-------------------------------------------------------------------------------"
    echo " Install some WF from OpenMSA github repo"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Process/; 
    echo "  >> BIOS_Automation"
    ln -fs ../OpenMSA_WF/BIOS_Automation BIOS_Automation
    ln -fs ../OpenMSA_WF/.meta_BIOS_Automation .meta_BIOS_Automation
 #   echo "  >> ETSI-MANO"
 #   ln -fs ../OpenMSA_MANO/WORKFLOWS/ETSI-MANO ETSI-MANO
 #   ln -fs ../OpenMSA_MANO/WORKFLOWS/.meta_ETSI-MANO .meta_ETSI-MANO
    echo "  >> Private Cloud - Openstack"
    ln -fs ../OpenMSA_WF/Private_Cloud Private_Cloud
    ln -fs ../OpenMSA_WF/.meta_Private_Cloud .meta_Private_Cloud
    echo "  >> Ansible"
    ln -fs ../OpenMSA_WF/Ansible Ansible
    ln -fs ../OpenMSA_WF/.meta_Ansible .meta_Ansible
    echo "  >> Public Cloud - AWS"
    ln -fs ../OpenMSA_WF/Public_Cloud Public_Cloud
    ln -fs ../OpenMSA_WF/.meta_Public_Cloud .meta_Public_Cloud
 
    echo "DONE"

}

install_adapters() {
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
    #install_adapter cisco_nexus9000
    install_adapter cisco_isr
    #install_adapter cisco_asr
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
    install_adapter openstack_keystone_v3
    install_adapter fortigate
    install_adapter fortiweb
    #install_adapter fortinet_fortimanager
    #install_adapter fortinet_fortianalyzer
    #install_adapter fortinet_jsonapi
    install_adapter paloalto_chassis
    install_adapter paloalto_generic
    install_adapter paloalto_vsys
    install_adapter netconf_generic
    #install_adapter juniper_srx
    #install_adapter juniper_contrail
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
    install_adapter huawei_generic
    install_adapter citrix_adc
    install_adapter ansible_generic
    install_adapter mikrotik_generic

    ln -fs /opt/devops/OpenMSA_Adapters/vendor /opt/sms/bin/php/vendor
    #install_adapter stormshield 
    #install_adapter a10_thunder 
}

finalize_install() {
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
    chown -R ncuser:ncuser /opt/sms/devices/; \
    #chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
    echo "DONE"

    echo "-------------------------------------------------------------------------------"
    echo " service restart"
    echo "-------------------------------------------------------------------------------"
    echo "  >> execute [sudo docker-compose restart msa_api] to restart the API service"
    echo "  >> execute [sudo docker-compose exec msa_sms /etc/init.d/ubi-sms restart] to restart the CoreEngine service"
    echo "DONE"
}

usage() {
	echo "usage: $PROG [all|ms|wf|da]"
    echo "this script installs some librairies available @github.com/openmsa"
	echo
	echo "all (default): install everyting: worflows, microservices and adapters"
	echo "ms: install the microservices from https://github.com/openmsa/Microservices"
	echo "wf: install the worflows from https://github.com/openmsa/Workflows"
	echo "da: install the adapters from https://github.com/openmsa/Adapters"
    exit 0
}

main() {


	cmd=$1
	shift
	case $cmd in
		""|all)
            update_github_repo
            install_microservices;
            install_workflows;
            install_adapters;
			;;
		ms)
            update_github_repo
			install_microservices 
			;;
		wf)
            update_github_repo
			install_workflows 
			;;
		da)
            update_github_repo
			install_adapters
			;;

		*)
			fatal "unknown command: $1"
            usage
			;;
	esac
    finalize_install
}


main "$@"
