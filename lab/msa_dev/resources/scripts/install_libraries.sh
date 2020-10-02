#!/bin/bash
#set -x

PROG=$(basename $0)

install_license() {

    echo "-------------------------------------------------------"
    echo "INSTALL EVAL LICENSE"
    echo "-------------------------------------------------------"
    if [ -z "$1"  ]
    then
        /usr/bin/install_license.sh
        if [ $? -ne 0 ]; then
            exit 1
        fi
    else
        echo "skipping license installation"
    fi
}

init_intall() {
    
    git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"; \
    git config --global push.default simple; \
    
    mkdir -p /opt/fmc_entities; \
    mkdir -p /opt/fmc_repository/CommandDefinition; \
    mkdir -p /opt/fmc_repository/CommandDefinition/microservices; \
    mkdir -p /opt/fmc_repository/Configuration; \
    mkdir -p /opt/fmc_repository/Datafiles; \
    mkdir -p /opt/fmc_repository/Documentation; \
    mkdir -p /opt/fmc_repository/Firmware; \
    mkdir -p /opt/fmc_repository/License; \
    mkdir -p /opt/fmc_repository/Process; \

    chown -R ncuser.ncuser /opt/fmc_repository /opt/fmc_entities
    
}

update_github_repo() {
    echo "-------------------------------------------------------------------------------"
    echo " Update the github repositories "
    echo "-------------------------------------------------------------------------------"
    git config --global user.email devops@openmsa.co
    cd /opt/devops ; 
    echo "  >> https://github.com/openmsa/Adapters.git "
    if [ -d OpenMSA_Adapters ]; 
    then 
        cd OpenMSA_Adapters; 
        git stash;
        git checkout master;
        git pull;
        git stash pop;
    else 
        git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; 
        cd OpenMSA_Adapters; 
    fi ;
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout 2.2.0GA;
    git pull
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### MS ###
    echo "  >> https://github.com/openmsa/Microservices.git "
    cd /opt/fmc_repository ; 
    if [ -d OpenMSA_MS ]; 
    then  
        cd OpenMSA_MS; 
        git stash;
        git checkout master;
        git pull;
    else 
        git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; 
        cd OpenMSA_MS; 
    fi;
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout 2.2.0GA;
    git pull
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### WF ###
    echo "  >> https://github.com/openmsa/Workflows.git "
    cd /opt/fmc_repository ; 
    if [ -d OpenMSA_WF ]; 
    then 
        cd OpenMSA_WF;
        git stash;
        git checkout master;
        git pull;
    else 
        git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; 
        cd OpenMSA_WF;
    fi ; 
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout 2.2.0GA;
    git pull
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    else 
        git clone https://github.com/ubiqube/quickstart.git quickstart; 
    fi ;
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    git checkout 2.2.0GA;
    git pull
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
    ln -fsn ../OpenMSA_MS/ADVA ADVA; ln -fsn ../OpenMSA_MS/.meta_ADVA .meta_ADVA; 
    echo "  >> ANSIBLE"
    ln -fsn ../OpenMSA_MS/ANSIBLE ANSIBLE; ln -fsn ../OpenMSA_MS/.meta_ANSIBLE .meta_ANSIBLE; 
    echo "  >> AWS"
    ln -fsn ../OpenMSA_MS/AWS AWS; ln -fsn ../OpenMSA_MS/.meta_AWS .meta_AWS; 
    echo "  >> CHECKPOINT"
    ln -fsn ../OpenMSA_MS/CHECKPOINT CHECKPOINT; ln -fsn ../OpenMSA_MS/.meta_CHECKPOINT .meta_CHECKPOINT; 
    echo "  >> CISCO"
    ln -fsn ../OpenMSA_MS/CISCO CISCO; ln -fsn ../OpenMSA_MS/.meta_CISCO .meta_CISCO; 
    echo "  >> CITRIX"
    ln -fsn ../OpenMSA_MS/CITRIX CITRIX; ln -fsn ../OpenMSA_MS/.meta_CITRIX .meta_CITRIX; 
    echo "  >> FLEXIWAN"
    ln -fsn ../OpenMSA_MS/FLEXIWAN FLEXIWAN; ln -fsn ../OpenMSA_MS/.meta_FLEXIWAN .meta_FLEXIWAN; 
    echo "  >> FORTINET"
    ln -fsn ../OpenMSA_MS/FORTINET FORTINET; ln -fsn ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; 
    echo "  >> JUNIPER"
    ln -fsn ../OpenMSA_MS/JUNIPER JUNIPER; ln -fsn ../OpenMSA_MS/.meta_JUNIPER .meta_JUNIPER;
    rm -rf  JUNIPER/SSG
    echo "  >> LINUX"
    ln -fsn ../OpenMSA_MS/LINUX LINUX; ln -fsn ../OpenMSA_MS/.meta_LINUX .meta_LINUX; 
    echo "  >> MIKROTIK"
    ln -fsn ../OpenMSA_MS/MIKROTIK MIKROTIK; ln -fsn ../OpenMSA_MS/.meta_MIKROTIK .meta_MIKROTIK; 
    echo "  >> OPENSTACK"
    ln -fsn ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -fsn ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; 
    echo "  >> ONEACCESS"
    ln -fsn ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -fsn ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; 
    echo "  >> PALOALTO"
    ln -fsn ../OpenMSA_MS/PALOALTO PALOALTO; ln -fsn ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; 
    echo "  >> PFSENSE"
    ln -fsn ../OpenMSA_MS/PFSENSE PFSENSE; ln -fsn ../OpenMSA_MS/.meta_PFSENSE .meta_PFSENSE; 
    echo "  >> REDFISHAPI"
    ln -fsn ../OpenMSA_MS/REDFISHAPI REDFISHAPI; ln -fsn ../OpenMSA_MS/.meta_REDFISHAPI .meta_REDFISHAPI; 
    echo "  >> REST"
    ln -fsn ../OpenMSA_MS/REST REST; ln -fsn ../OpenMSA_MS/.meta_REST .meta_REST; 
    echo "  >> ETSI-MANO"
    ln -fsn ../OpenMSA_MS/NFVO NFVO;  ln -fsn ../OpenMSA_MS/.meta_NFVO .meta_NFVO
    ln -fsn ../OpenMSA_MS/VNFM VNFM; ln -fsn ../OpenMSA_MS/.meta_VNFM .meta_VNFM
    ln -fsn ../OpenMSA_MS/KUBERNETES KUBERNETES; ln -fsn ../OpenMSA_MS/.meta_KUBERNETES .meta_KUBERNETES
    echo "  >> NETBOX"
    ln -fsn ../OpenMSA_MS/NETBOX NETBOX; ln -fsn ../OpenMSA_MS/.meta_NETBOX .meta_NETBOX; 

    echo "DONE"

}

install_workflows() {

    echo "-------------------------------------------------------------------------------"
    echo " Install some WF from OpenMSA github github repository"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Process; \
    echo "  >> WF references and libs"
    ln -fsn ../OpenMSA_WF/Reference Reference; \
    ln -fsn ../OpenMSA_WF/.meta_Reference .meta_Reference; \
    echo "  >> WF tutorials"
    ln -fsn ../OpenMSA_WF/Tutorials Tutorials; \
    ln -fsn ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; \
    echo "  >> BIOS_Automation"
    ln -fsn ../OpenMSA_WF/BIOS_Automation BIOS_Automation
    ln -fsn ../OpenMSA_WF/.meta_BIOS_Automation .meta_BIOS_Automation
 #   echo "  >> ETSI-MANO"
 #   ln -fsn ../OpenMSA_MANO/WORKFLOWS/ETSI-MANO ETSI-MANO
 #   ln -fsn ../OpenMSA_MANO/WORKFLOWS/.meta_ETSI-MANO .meta_ETSI-MANO
    echo "  >> Private Cloud - Openstack"
    ln -fsn ../OpenMSA_WF/Private_Cloud Private_Cloud
    ln -fsn ../OpenMSA_WF/.meta_Private_Cloud .meta_Private_Cloud
    echo "  >> Ansible"
    ln -fsn ../OpenMSA_WF/Ansible Ansible
    ln -fsn ../OpenMSA_WF/.meta_Ansible .meta_Ansible
    echo "  >> Public Cloud - AWS"
    ln -fsn ../OpenMSA_WF/Public_Cloud Public_Cloud
    ln -fsn ../OpenMSA_WF/.meta_Public_Cloud .meta_Public_Cloud
    echo "  >> Topology"
    ln -fsn ../OpenMSA_WF/Topology Topology
    ln -fsn ../OpenMSA_WF/.meta_Topology .meta_Topology
    echo "  >> MSA / Utils"
    ln -fsn ../OpenMSA_WF/Utils/Assign_Device_Variables Assign_Device_Variables
    ln -fsn ../OpenMSA_WF/Utils/.meta_Assign_Device_Variables .meta_Assign_Device_Variables


    echo "-------------------------------------------------------------------------------"
    echo " Install mini lab setup WF from quickstart github repository"
    echo "-------------------------------------------------------------------------------"
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/SelfDemoSetup SelfDemoSetup; \
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/.meta_SelfDemoSetup .meta_SelfDemoSetup; \

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
    install_adapter fortinet_generic
    install_adapter fortiweb
    #install_adapter fortinet_fortimanager
    #install_adapter fortinet_fortianalyzer
    #install_adapter fortinet_jsonapi
    install_adapter paloalto_chassis
    install_adapter paloalto_generic
    install_adapter paloalto_vsys
    install_adapter netconf_generic
    install_adapter juniper_srx
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
    install_adapter rest_netbox
    install_adapter juniper_rest

    ln -fsn /opt/devops/OpenMSA_Adapters/vendor /opt/sms/bin/php/vendor
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
    chown -R ncuser:ncuser /opt/fmc_repository
    chown -R ncuser:ncuser /opt/fmc_repository/.meta_*
    chown -R ncuser:ncuser /opt/sms/bin/php
    chown -R ncuser:ncuser /opt/sms/devices
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters

    echo "DONE"

    echo "-------------------------------------------------------------------------------"
    echo " service restart"
    echo "-------------------------------------------------------------------------------"
    echo "  >> execute [sudo docker-compose restart msa_api] to restart the API service"
    echo "  >> execute [sudo docker-compose restart msa_sms] to restart the CoreEngine service"
    echo "DONE"
}

usage() {
	echo "usage: $PROG [all|ms|wf|da] [--no-lic]"
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
    option=$2
	shift
	case $cmd in
		""|all)
            install_license $option
            init_intall
            update_github_repo
            install_microservices;
            install_workflows;
            install_adapters;
			;;
		ms)
            install_license  $option
            init_intall
            update_github_repo
			install_microservices 
			;;
		wf)
            install_license  $option
            init_intall
            update_github_repo
			install_workflows 
			;;
		da)
            install_license  $option
            init_intall
            update_github_repo
			install_adapters
			;;

		*)
            echo "Error: unknown command: $1"
            usage
			;;
	esac
    finalize_install
}


main "$@"
