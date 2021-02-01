#!/bin/bash
#set -x

PROG=$(basename $0)

DEV_BRANCH=default_dev_branch
GITHUB_DEFAULT_BRANCH=master
QUICKSTART_DEFAULT_BRANCH=master
INSTALL_LICENSE=false
ASSUME_YES=false

install_license() {

    if [ $INSTALL_LICENSE == true  ];
    then
        echo "-------------------------------------------------------"
        echo "INSTALL EVAL LICENSE"
        echo "-------------------------------------------------------"
        /usr/bin/install_license.sh
        if [ $? -ne 0 ]; then
            exit 1
        fi
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
        if [[ $ASSUME_YES == false && $CURRENT_BR == "master" ]];
        then
            echo "> WARNING: your current branch is $CURRENT_BR, to be safe, you may want to switch to a working branch (default_dev_branch is the factory default for development)"
            read -p  "> switch ? [y]/[N]" yn
            case $yn in
                [Yy]* )
                    read -p   "> Enter the name of the working branch (enter $CURRENT_BR to stay on your current branch):" br
                    if [ $br == "" ];
                    then
                        echo "> ERROR: invalid branch name, exiting..."
                        exit 0
                    else
                        # checkout or create and checkout the branch
                        echo "> Switching to $br (the branch will be created if it doesn't exist yet)"
                        git checkout $br 2>/dev/null || git checkout -b $br
                        CURRENT_BR=$br
                    fi
                    ;;
                [Nn]* )
                    read -p  "> stay on master ? [y]/[N]" resp
                    if [[ $resp != "" && $resp == "y" ]];
                    then
                        echo "> running installation/update on master branch on local repository"
                    else
                        echo "> cancelling installation, exiting... "
                        exit 0
                    fi
                    ;;
                * )
                    echo "> exiting... "
                    exit 0
                   ;;
            esac
        fi
        git stash
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
                        git pull origin $DEFAULT_BRANCH --prune; break
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
                git pull origin $DEFAULT_BRANCH --prune
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

    if [[ $install_type = "all" || $install_type = "mano" ]];
    then
       update_git_repo "https://github.com/openmsa/etsi-mano.git" "/opt/fmc_repository" "OpenMSA_MANO" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
    fi

    if [[ $install_type = "all" || $install_type = "py" ]];
    then
        update_git_repo "https://github.com/openmsa/python-sdk.git" "/tmp/" "python_sdk" "develop" "default_dev_branch"
    fi

    if [[ $install_type = "all" || $install_type = "quickstart" ]];
    then    
        update_git_repo "https://github.com/ubiqube/quickstart.git" "/opt/fmc_repository" "quickstart" $QUICKSTART_DEFAULT_BRANCH 
    fi
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

install_python_sdk() {
    mkdir -p /opt/fmc_repository/Process/PythonReference/custom
    touch /opt/fmc_repository/Process/PythonReference/custom/__init__.py
    pushd /tmp/python_sdk
    python3 setup.py install --install-lib='/opt/fmc_repository/Process/PythonReference'
    popd
    rm -rf /tmp/python_sdk
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
    echo "  >> DELL/REDFISH"
    ln -fsn ../OpenMSA_MS/DELL DELL; ln -fsn ../OpenMSA_MS/.meta_DELL .meta_DELL; 
    echo "  >> INTEL/REDFISH"
    ln -fsn ../OpenMSA_MS/INTEL INTEL; ln -fsn ../OpenMSA_MS/.meta_INTEL .meta_INTEL; 
    echo "  >> HP/REDFISH"
    ln -fsn ../OpenMSA_MS/HP HP; ln -fsn ../OpenMSA_MS/.meta_HP .meta_HP; 
    echo "  >> LANNER/IPMI"
    ln -fsn ../OpenMSA_MS/LANNER LANNER; ln -fsn ../OpenMSA_MS/.meta_LANNER .meta_LANNER; 

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
    echo "  >> Analytics"
    ln -fsn ../OpenMSA_WF/Analytics Analytics
    echo "  >> MSA / Utils"
    ln -fsn ../OpenMSA_WF/Utils/Manage_Device_Conf_Variables Manage_Device_Conf_Variables
    ln -fsn ../OpenMSA_WF/Utils/.meta_Manage_Device_Conf_Variables .meta_Manage_Device_Conf_Variables
    echo "  >> MSA / Utils"
    ln -fsn ../OpenMSA_WF/BIOS_Automation BIOS_Automation
    ln -fsn ../OpenMSA_WF/.meta_BIOS_Automation .meta_BIOS_Automation


    echo "-------------------------------------------------------------------------------"
    echo " Install mini lab setup WF from quickstart github repository"
    echo "-------------------------------------------------------------------------------"
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/SelfDemoSetup SelfDemoSetup; \
    ln -fsn ../quickstart/lab/msa_dev/resources/libraries/workflows/.meta_SelfDemoSetup .meta_SelfDemoSetup; \

    echo "DONE"

}

install_adapters() {
    local adapters=(

    #a10_thunder
    a10_thunder_axapi
    adtran_generic
    adva_nc
    ansible_generic
    aws_generic
    brocade_vyatta
    catalyst_ios
    checkpoint_r80
    cisco_apic
    cisco_asa_generic
    cisco_asa_rest
    #cisco_asr
    cisco_isr
    #cisco_nexus9000
    citrix_adc
    dell_redfish
    esa
    f5_bigip
    fortigate
    #fortinet_fortianalyzer
    #fortinet_fortimanager
    fortinet_generic
    #fortinet_jsonapi
    fortiweb
    fujitsu_ipcom
    hp2530
    hp5900
    hpe_redfish
    huawei_generic
    intel_redfish
    #juniper_contrail
    juniper_rest
    juniper_srx
    kubernetes_generic
    lanner_ipmi
    linux_generic
    linux_k8_cli
    mikrotik_generic
    mon_checkpoint_fw
    mon_cisco_asa
    mon_cisco_ios
    mon_fortinet_fortigate
    mon_generic
    nec_intersecvmlb
    nec_intersecvmsg
    nec_ix
    nec_nfa
    nec_pflow_p4_unc
    nec_pflow_pfcscapi
    netconf_generic
    nfvo_generic
    nokia_cloudband
    nokia_vsd
    oneaccess_lbb
    oneaccess_netconf
    oneaccess_whitebox
    opendaylight
    openstack_keystone_v3
    paloalto
    paloalto_chassis
    paloalto_generic
    paloalto_vsys
    pfsense_fw
    rancher_cmp
    redfish_generic
    rest_generic
    rest_netbox
    #stormshield
    veex_rtu
    versa_analytics
    versa_appliance
    versa_director
    virtuora_nc
    vmware_vsphere
    vnfm_generic
    wsa
    )

    for adapter in ${adapters[@]}; do install_adapter $adapter; done
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
    chown -R ncuser:ncuser /opt/fmc_repository/*; 
    if [[ $install_type = "all" || $install_type = "da" ]];
    then 
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters/adapters/*
    chown -R ncuser.ncuser /opt/devops/OpenMSA_Adapters/vendor/*
    fi

    echo "DONE"
    if [[ $install_type = "all" || $install_type = "da" ]];
    then
        echo "-------------------------------------------------------------------------------"
        echo " service restart"
        echo "-------------------------------------------------------------------------------"
        echo "  >> execute [sudo docker-compose restart msa_sms] to restart the CoreEngine service"
        echo "  >> execute [sudo docker-compose restart msa_api] to restart the API service"
        echo "DONE"
    fi
}

usage() {
    echo "usage: $PROG all|ms|wf|da|py|mano|quickstart [--lic] [-y]"
    echo
    echo "this script installs some librairies available @github.com/openmsa"
    echo
    echo "Commands:"
	echo "all:          install/update everything: workflows, microservices and adapters"
	echo "ms:           install/update the microservices from https://github.com/openmsa/Microservices"
	echo "wf:           install/update the worfklows from https://github.com/openmsa/Workflows"
	echo "da:           install/update the adapters from https://github.com/openmsa/Adapters"
    echo "mano:         install/update the python-sdk from https://github.com/openmsa/etsi-mano"
    echo "py:           install/update the python-sdk from https://github.com/openmsa/python-sdk"
    echo "quickstart:   install/update the local quickstart from https://github.com/ubiqube/quickstart"
    echo
    echo "Options:"
    echo "--lic:          force license installation"
    echo "-y:             answer yes for all questions"
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
            --lic)
                INSTALL_LICENSE=true
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
            install_python_sdk
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
        py)
            init_intall
            update_all_github_repo  $cmd
            install_python_sdk
            ;;
        mano)
            init_intall
            update_all_github_repo  $cmd
            ;;
        quickstart)
            init_intall
            update_all_github_repo  $cmd
            ;;
		*)
            echo "Error: unknown command: $1"
            usage
			;;
	esac
    finalize_install
}


main "$@"
