#!/bin/bash
#set -x

PROG=$(basename $0)

DEV_BRANCH=default_dev_branch
GITHUB_DEFAULT_BRANCH=master
QUICKSTART_DEFAULT_BRANCH=master
INSTALL_LICENSE=true
ASSUME_YES=false

install_license() {

    echo "-------------------------------------------------------"
    echo "INSTALL EVAL LICENSE"
    echo "-------------------------------------------------------"
    if [ $INSTALL_LICENSE == true  ];
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

update_git_repo () {

    REPO_URL=$1
    REPO_BASE_DIR=$2
    REPO_DIR=$3
    DEFAULT_BRANCH=$4
    DEFAULT_DEV_BRANCH=$5
    
    cd $REPO_BASE_DIR
    echo ">> "
    echo ">> $REPO_URL"
    if [ -d $REPO_DIR ]; 
    then 
        cd $REPO_DIR
        ## get current branch and store in variable CURRENT_BR
        CURRENT_BR=`git rev-parse --abbrev-ref HEAD`
        echo "> Current working branch: $CURRENT_BR"
        git stash;
        echo "> Checking merge $DEFAULT_BRANCH to $CURRENT_BR"
        git merge --no-commit --no-ff $DEFAULT_BRANCH
        CAN_MERGE=$?
        if [ $CAN_MERGE == 0 ];
        then
            echo "> Auto-merge $DEFAULT_BRANCH to $CURRENT_BR is possible"
            if [ $ASSUME_YES == false ];
            then
                while true; do
                echo "> merge $DEFAULT_BRANCH to current working branch $CURRENT_BR ?"
                read -p  "[y]/[N]" yn
                case $yn in
                    [Yy]* )
                        git pull origin $DEFAULT_BRANCH; break
                    ;;
                    [Nn]* ) 
                        echo "> skip merge "
                        break
                    ;;
                    * ) 
                        echo "Please answer yes or no."
                    ;;
                esac
                done
            else
                git pull origin $DEFAULT_BRANCH
            fi
        else
            echo "> WARN: conflict found when merging $DEFAULT_BRANCH to $CURRENT_BR."
            echo ">       auto-merge not possible"
            echo ">       login to the container msa_dev and merge manually if merge is needed"
            echo ">       git repository at $REPO_BASE_DIR/$REPO_DIR"
            git merge --abort
        fi;

       echo "> Check out $DEFAULT_BRANCH and get the latest code"
        git checkout $DEFAULT_BRANCH;
        git pull;
        echo "> Back to working branch"
        git checkout $CURRENT_BR
        git stash pop
    else 
        git clone $REPO_URL $REPO_DIR
        cd $REPO_DIR
        git checkout $DEFAULT_BRANCH;
        if [ $DEFAULT_DEV_BRANCH != ""  ];
        then
            echo "> Create a new developement branch: $DEFAULT_DEV_BRANCH based on $DEFAULT_BRANCH"
            git checkout -b $DEFAULT_DEV_BRANCH
        fi
    fi;
    echo ">>"
    echo ">> DONE"
}


update_all_github_repo() {
    echo "-------------------------------------------------------------------------------"
    echo " Update the github repositories "
    echo "-------------------------------------------------------------------------------"
    install_type=$1
    git config --global user.email devops@openmsa.co
    
    if [[ $install_type = "all" || $install_type = "da" ]];
    then
        update_git_repo "https://github.com/openmsa/Adapters.git" "/opt/devops" "OpenMSA_Adapters" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
    fi
    
    if [[ $install_type = "all" || $install_type = "ms" ]];
    then
        update_git_repo "https://github.com/openmsa/Microservices.git" "/opt/fmc_repository" "OpenMSA_MS" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
    fi
    
    if [[ $install_type = "all" || $install_type = "wf" ]];
    then
        update_git_repo "https://github.com/openmsa/Workflows.git" "/opt/fmc_repository" "OpenMSA_WF" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
    fi

    update_git_repo "https://github.com/openmsa/etsi-mano.git" "/opt/fmc_repository" "OpenMSA_MANO" $GITHUB_DEFAULT_BRANCH "default_dev_branch"

    update_git_repo "https://github.com/ubiqube/quickstart.git" "/opt/fmc_repository" "quickstart" $QUICKSTART_DEFAULT_BRANCH 

}

uninstall_adapter() {
    DEVICE_DIR=$1
    echo "-------------------------------------------------------------------------------"
    echo " Uninstall $DEVICE_DIR adapter source code from github repo "
    echo "-------------------------------------------------------------------------------"
    /opt/devops/OpenMSA_Adapters/bin/da_installer uninstall /opt/devops/OpenMSA_Adapters/adapters/$DEVICE_DIR
}

#
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
    ln -fsn ../OpenMSA_WF/Ansible_integration Ansible_integration
    #ln -fsn ../OpenMSA_WF/.meta_Ansible_integration .meta_Ansible_integration
    echo "  >> Public Cloud - AWS"
    ln -fsn ../OpenMSA_WF/Public_Cloud Public_Cloud
    ln -fsn ../OpenMSA_WF/.meta_Public_Cloud .meta_Public_Cloud
    echo "  >> Topology"
    ln -fsn ../OpenMSA_WF/Topology Topology
    ln -fsn ../OpenMSA_WF/.meta_Topology .meta_Topology
    echo "  >> MSA / Utils"
    ln -fsn ../OpenMSA_WF/Utils/Manage_Device_Conf_Variables Manage_Device_Conf_Variables
    ln -fsn ../OpenMSA_WF/Utils/.meta_Manage_Device_Conf_Variables .meta_Manage_Device_Conf_Variables


    echo "-------------------------------------------------------------------------------"
    echo " Install mini lab setup WF from quickstart github repository"
    echo "-------------------------------------------------------------------------------"
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/SelfDemoSetup SelfDemoSetup; \
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/.meta_SelfDemoSetup .meta_SelfDemoSetup; \

    echo "DONE"

}

install_adapters() {
    #install_adapter a10_thunder
    install_adapter a10_thunder_axapi
    install_adapter adtran_generic
    install_adapter adva_nc
    install_adapter ansible_generic
    install_adapter aws_generic
    install_adapter brocade_vyatta
    install_adapter catalyst_ios
    install_adapter checkpoint_r80
    install_adapter cisco_apic
    install_adapter cisco_asa_generic
    install_adapter cisco_asa_rest
    #install_adapter cisco_asr
    install_adapter cisco_isr
    #install_adapter cisco_nexus9000
    install_adapter citrix_adc
    install_adapter esa
    install_adapter f5_bigip
    install_adapter fortigate
    #install_adapter fortinet_fortianalyzer
    #install_adapter fortinet_fortimanager
    install_adapter fortinet_generic
    #install_adapter fortinet_jsonapi
    install_adapter fortiweb
    install_adapter fujitsu_ipcom
    install_adapter hp2530
    install_adapter hp5900
    install_adapter huawei_generic
    #install_adapter juniper_contrail
    install_adapter juniper_rest
    install_adapter juniper_srx
    install_adapter kubernetes_generic
    install_adapter linux_generic
    install_adapter linux_k8_cli
    install_adapter mikrotik_generic
    install_adapter mon_checkpoint_fw
    install_adapter mon_cisco_asa
    install_adapter mon_cisco_ios
    install_adapter mon_fortinet_fortigate
    install_adapter mon_generic
    install_adapter nec_intersecvmlb
    install_adapter nec_intersecvmsg
    install_adapter nec_ix
    install_adapter nec_nfa
    install_adapter nec_pflow_p4_unc
    install_adapter nec_pflow_pfcscapi
    install_adapter netconf_generic
    install_adapter nfvo_generic
    install_adapter nokia_cloudband
    install_adapter nokia_vsd
    install_adapter oneaccess_lbb
    install_adapter oneaccess_netconf
    install_adapter oneaccess_whitebox
    install_adapter opendaylight
    install_adapter openstack_keystone_v3
    install_adapter paloalto
    install_adapter paloalto_chassis
    install_adapter paloalto_generic
    install_adapter paloalto_vsys
    install_adapter pfsense_fw
    install_adapter rancher_cmp
    install_adapter redfish_generic
    install_adapter rest_generic
    install_adapter rest_netbox
    #install_adapter stormshield
    install_adapter veex_rtu
    install_adapter versa_analytics
    install_adapter versa_appliance
    install_adapter versa_director
    install_adapter virtuora_nc
    install_adapter vmware_vsphere
    install_adapter vnfm_generic
    install_adapter wsa
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
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters/adapters/*
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters/vendor/*

    echo "DONE"

    echo "-------------------------------------------------------------------------------"
    echo " service restart"
    echo "-------------------------------------------------------------------------------"
    echo "  >> execute [sudo docker-compose restart msa_api] to restart the API service"
    echo "  >> execute [sudo docker-compose restart msa_sms] to restart the CoreEngine service"
    echo "DONE"
}

usage() {
	echo "usage: $PROG all|ms|wf|da [--no-lic] [-y]"
  echo
  echo "this script installs some librairies available @github.com/openmsa"
	echo
  echo "Commands:"
	echo "all:          install everything: worflows, microservices and adapters"
	echo "ms:           install the microservices from https://github.com/openmsa/Microservices"
	echo "wf:           install the worflows from https://github.com/openmsa/Workflows"
	echo "da:           install the adapters from https://github.com/openmsa/Adapters"
  echo "Options:"
  echo "--no-lic:     skip license installation"
  echo "-y:           answer yes for all questions"
  exit 0
}

main() {


	cmd=$1

    if [ $cmd == --help ];
    then
        usage
    fi

   	shift

    while [ ! -z $1 ]
    do
        echo $1
        option=$1
        case $option in
            --no-lic)
                INSTALL_LICENSE=false
                ;;
            -y)
                ASSUME_YES=true
                ;;
            *)
            echo "Error: unknown option: $option"
            usage
			;;
        esac
        shift
    done   

	case $cmd in
		all)
            install_license $option
            init_intall
            update_all_github_repo $cmd
            install_microservices;
            install_workflows;
            install_adapters;
			;;
		ms)
            install_license  $option
            init_intall
            update_all_github_repo  $cmd
			install_microservices 
			;;
		wf)
            install_license  $option
            init_intall
            update_all_github_repo  $cmd
			install_workflows 
			;;
		da)
            install_license  $option
            init_intall
            update_all_github_repo  $cmd
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
