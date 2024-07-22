#!/bin/bash
#set -x

. /usr/share/install-libraries/il-lib.sh
PROG=$(basename "$0")

GITHUB_DEFAULT_BRANCH=master
INSTALL_LICENSE=false
ASSUME_YES=false

#
# versioning of the libraries that are installed by the script
#
TAG_WF_KIBANA_DASHBOARD=v2.8.13     # https://github.com/openmsa/workflow_kibana
TAG_WF_TOPOLOGY=v2.8.13             # https://github.com/openmsa/workflow_topology
TAG_PHP_SDK=v2.8.13                 # https://github.com/openmsa/php-sdk
TAG_WF_MINILAB=v2.6.0               # https://github.com/ubiqube/workflow_quickstart_minilab
TAG_WF_ETSI_MANO=v3.1.0             # https://github.com/openmsa/etsi-mano-workflows
TAG_BLUEPRINTS=CCLA-2.3.0           # https://github.com/openmsa/Blueprints
TAG_PYTHON_SDK=v2.8.13               # https://github.com/openmsa/python-sdk
TAG_ADAPTER=v2.8.13                 # https://github.com/openmsa/Adapters
TAG_MICROSERVICES=v2.8.13           # https://github.com/openmsa/Microservices
TAG_WORKFLOWS=v2.8.13               # https://github.com/openmsa/Workflows

install_license() {
    if [ $INSTALL_LICENSE == true  ]
    then
        emit_header "INSTALL EVAL LICENSE"
        /usr/bin/install_license.sh
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
}

init_intall() {
    emit_header "Init."
    emit_step "Creating default directories."
    color mkdir -p /opt/fmc_entities;
    color mkdir -p /opt/fmc_repository/CommandDefinition/microservices;
    color mkdir -p /opt/fmc_repository/Configuration;
    color mkdir -p /opt/fmc_repository/Datafiles/Environments;
    color mkdir -p /opt/fmc_repository/Documentation;
    color mkdir -p /opt/fmc_repository/Firmware;
    color mkdir -p /opt/fmc_repository/License;
    color mkdir -p /opt/fmc_repository/Process;
    color mkdir -p /opt/fmc_repository/Blueprints/local;
    color mkdir -p /opt/fmc_repository/Pki;
    color mkdir -p /opt/fmc_repository/Shared;
    emit_step "Initialize metadata."
    color cp -n /usr/share/install-libraries/meta/.meta* /opt/fmc_repository/
    color chown -R ncuser.ncuser /opt/fmc_repository /opt/fmc_entities
    emit_step "Upgrade pip."
    python3 -m pip install --upgrade pip --target=/opt/fmc_repository/Process/PythonReference/
    emit_done
}

#
# Create a branch from a gven tag name
#     $1: TAG.
#
create_branch() {
    TAG="$1"
    emit_step "Create a new branch: %b based on the tag %b" "$TAG" "$TAG"
    git checkout "tags/$TAG" -b "$TAG"
}

show_tags() {
    git fetch --tags
    emit_step "available release tags: "
    echo -ne "${color_head}"
    git tag -l 'v*' | sort --version-sort | tr '\n' ' '
    echo -e "${color_none}"
}

is_remote_branch() {
    branch="$1"
    res="$(git ls-remote --heads origin $branch)"
    if [[ -z "$res" ]]
    then
        return 1
    fi
    return 0
}
is_local_branch() {
    branch="$1"
    res="$(git branch --list $branch)"
    if [[ -z "$res" ]]
    then
        return 1
    fi
    return 0
}

STAG="none"
select_tag() {
    TAG="$1"
    while [ ! $(git tag --list "$TAG") ]
    do
        if [[ "$ASSUME_YES" == true ]]
        then
            echo -e "> ${color_warning}cancelling installation, of ${color_param}$REPO_DIR${color_none}"
            unset STAG
            return 1
        fi
        show_tags
        echo -e "> ${color_warning}WARNING${color_none}: tag ${color_param}$TAG${color_none} not found, current branch is ${color_param}$CURRENT_BR${color_none}"
        echo -e "> (a) Abort installation"
        echo -e "> (t) Choose a tag"
        read -p  "[a]/[t]: " resp
        if [[ $resp == "t" ]]
        then
            echo -n "Input tag: "
            read tag
            TAG=$tag
        elif [[ $resp == "a" ]]
        then
            echo -e "> ${color_warning}cancelling installation, of ${color_param}$REPO_DIR${color_none}"
            unset STAG
            return 1
        fi
    done
    STAG="$TAG"
}

show_branchs() {
    emit_step "available release branches:"
    echo -ne "${color_head}"
    git branch --list -a | sort --version-sort | tr '\n' ' '
    echo -e "${color_none}"
}

SBRANCH=
ask_branch() {
    BRANCH=$1
    color git fetch
    while ! (is_local_branch "$BRANCH" || is_remote_branch "$BRANCH")
    do
        if [[ "$ASSUME_YES" == true ]]
        then
            echo -e "> ${color_warning}cancelling installation, of ${color_param}$REPO_DIR${color_none}"
            unset SBRANCH
            return 1
        fi
        show_branchs
        echo -e "> ${color_warning}WARNING${color_none}: branch ${color_param}$BRANCH${color_none} not found, current branch is ${color_param}$CURRENT_BR${color_none}"
        echo -e "> (a) Abort installation"
        echo -e "> (b) Choose a branch"
        read -p  "[a]/[b]: " resp
        if [[ $resp == "b" ]]
        then
            echo -n "Input branch: "
            read branch
            BRANCH=$branch
        elif [[ $resp == "a" ]]
        then
            echo -e "> ${color_warning}cancelling installation, of ${color_param}$REPO_DIR${color_none}"
            unset SBRANCH
            return 1
        fi
    done
    SBRANCH="$BRANCH"
}

ask_for_shell() {
    while true; do 
        if [[ "$ASSUME_YES" == true ]]
        then
            echo -e "> ${color_warning}cancelling installation, of ${color_param}$REPO_DIR${color_none}"
            return 1
        fi
        echo "[S] To open a shell to fix the problem."
        echo "[a] To abort the installation."
        read -p "[S] / [A]: " as
        case $as in
        [sS]* )
            bash --rcfile <(cat ~/.bashrc; echo 'PS1="[\u@\h \W]\ \e[39;1m(CTRL+D to leave)\e[0m $ "')
            break
        ;;
        [aA]* )
            emit_step "Aborting."
            return 1
        esac
    done
}

do_with_git() {
    while true; do
        git "$@"
        if [ ! $? ]
        then
            emit_warning "Unable to stash modifications."
            ask_for_shell || return 1
        else
            break
        fi
    done
}

update_git_repo () {
    REPO_URL=$1
    REPO_BASE_DIR=$2
    REPO_DIR=$3
    DEFAULT_BRANCH=${GBRANCH:-master}
    TAG=$4
    RESET_REPO=$5

    cd "$REPO_BASE_DIR" || exit 
    emit_step "Fetching %b" "$REPO_URL"
    if [ "$RESET_REPO" == true ]
    then
        emit_step "Deleting repository: %b" "$REPO_DIR"
        rm -rf "$REPO_DIR"
    fi

    if [ -d "$REPO_DIR" ]
    then
        cd "$REPO_DIR" || exit
        ## get current branch and store in variable CURRENT_BR
        CURRENT_BR=$(git rev-parse --abbrev-ref HEAD)
        emit_step "Current working branch: %b" "$CURRENT_BR"
        if [[ $ASSUME_YES == false ]]
        then
            if [[ -n "$TAG" ]]
            then
                emit_step "installing version %b for %b" "$TAG" "$REPO_DIR"
                select_tag "$TAG" || return 1
                TAG="$STAG"
                do_with_git "stash" || return 1
                emit_step "pulling master"
                git checkout master
                git pull
                if [ $(git branch --list "$TAG") ]
                then
                    emit_step "local branch %b already exists. (skipping)" "$CURRENT_BR"
                    git checkout "$TAG"
                else
                    create_branch "$TAG"
                fi
            elif [[ -n "$DEFAULT_BRANCH" ]]
            then
                emit_step "Check out %b and get the latest code" "$DEFAULT_BRANCH"
                ask_branch "$DEFAULT_BRANCH" || return 1
                DEFAULT_BRANCH=$SBRANCH
                git fetch
                git checkout "$DEFAULT_BRANCH"
                git pull
            fi
        else
            emit_step "Get the latest code" "$DEFAULT_BRANCH"
            git pull
        fi
    else
        git clone "$REPO_URL" "$REPO_DIR"
        cd "$REPO_DIR" || exit
        git checkout "$DEFAULT_BRANCH"
        if [ ! -z "$TAG" ]
        then
            create_branch "$tag"
        fi
    fi
    install_repo_deps.sh "$REPO_BASE_DIR/$REPO_DIR"
    emit_done
}

install_python_sdk() {
    emit_header "Install python SDK"
    update_git_repo "https://github.com/openmsa/python-sdk.git" "/opt/fmc_repository/" "python-sdk" "$GTAG" false  
    emit_done
}

install_php_sdk() {
    emit_header "Install php SDK"
    update_git_repo "https://github.com/openmsa/php-sdk.git" "/opt/fmc_repository" "php_sdk" "$GTAG" false
    emit_done
}

install_microservices () {
    emit_header "Install some MS from OpenMSA github repo"
    emit_step "Checkout Microservice code."
    update_git_repo "https://github.com/openmsa/Microservices.git" "/opt/fmc_repository" "OpenMSA_MS" "$GTAG" false
    emit_done
}

install_workflows() {
    emit_header "Install Workflows from OpenMSA github github repository"
    pushd /opt/fmc_repository/Process || exit
    emit_step "Checkout repositories."
    if [ -z "$GTAG" ]
    then
        unset TAG_WF_TOPOLOGY
        unset TAG_PHP_SDK
        unset TAG_WF_MINILAB
    fi
    emit_step " - workflow_kibana"
    update_git_repo "https://github.com/openmsa/workflow_kibana.git" "/opt/fmc_repository" "OpenMSA_Workflow_Kibana" "$TAG_WF_KIBANA_DASHBOARD" false
    emit_step " - workflow_topology"
    update_git_repo "https://github.com/openmsa/workflow_topology_py.git" "/opt/fmc_repository" "OpenMSA_Workflow_Topology" "$TAG_WF_TOPOLOGY" false
    emit_step " - Workflows"
    update_git_repo "https://github.com/openmsa/Workflows.git" "/opt/fmc_repository" "OpenMSA_WF" "$GTAG" false
    emit_step " - workflow_minilab"
    update_git_repo "https://github.com/ubiqube/workflow_quickstart_minilab.git" "/opt/fmc_repository" "workflow_quickstart_minilab" "$TAG_WF_MINILAB" true
    emit_step "WF references and libs"
    emit_step " - php-sdk"
    update_git_repo "https://github.com/openmsa/php-sdk.git" "/opt/fmc_repository" "php_sdk" "$TAG_PHP_SDK" false
    popd || exit
    emit_done
}

install_mano_workflows() {
    emit_header "Install ETSI MANO Workflows."
    pushd /opt/fmc_repository/Process || exit
    if [ -z "$GTAG" ]
    then
        unset TAG_WF_ETSI_MANO
    fi
    emit_step "Checkout mano repository."
    update_git_repo "https://github.com/openmsa/etsi-mano-workflows.git" "/opt/fmc_repository" "etsi-mano-workflows" "$TAG_WF_ETSI_MANO" false
    popd || exit
    emit_done
}

install_ccla_lib() {
    emit_header "Install Cloudclapp library from OpenMSA github repository"
    pushd /opt/fmc_repository/Blueprints || exit
    if [ -z "$GTAG" ]
    then
        unset TAG_BLUEPRINTS
    fi
    emit_step "Checkout Blueprint repository."
    update_git_repo "https://github.com/openmsa/Blueprints" "/opt/fmc_repository" "OpenMSA_Blueprints" "$TAG_BLUEPRINTS" false
    emit_done
}

finalize_install() {
    if [[ "$install_type" = "all" || "$install_type" = "da" ]]; then
        emit_header "Service restart"
        echo "  >> execute [sudo docker-compose restart msa_dev] to update the Repository"
        echo "  >> execute [sudo docker-compose restart msa_sms] to restart the CoreEngine service"
        echo "  >> execute [sudo docker-compose restart msa_api] to restart the API service"
        emit_done
    fi
}

install_adapters() {
    emit_header "Install adapters."
    update_git_repo "https://github.com/openmsa/Adapters.git" "/opt/devops" "OpenMSA_Adapters" "$GTAG" false
    emit_done
}

print_arg() {
    printf "${color_bold}%-15s${color_none}%s\n" "$1" "$2"
}

usage() {
    echo "usage: $PROG all|ms|wf|da|py|mano|quickstart [--lic] [-y] [-t tag] [-b branch]"
    echo
    echo "this script installs some librairies available @github.com/openmsa"
    echo
    echo "Commands:"
    print_arg "all" "Install/update: python-sdk, php-sdk, workflows, topology, microservices and adapters"
    print_arg "ms" "Install/update the microservices from https://github.com/openmsa/Microservices"
    print_arg "wf" "Install/update the worfklows from https://github.com/openmsa/Workflows"
    print_arg "da" "Install/update the adapters from https://github.com/openmsa/Adapters"
    print_arg "py" "Install/update the python-sdk from https://github.com/openmsa/python-sdk"
    print_arg "php" "Install/update the python-sdk from https://github.com/openmsa/php-sdk"
    print_arg "mano" "Install/update the mano WF from https://github.com/openmsa/etsi-mano-workflows and install the python sdk ETSI"
    print_arg "ccla" "Install/update the cloudclapp libraries, like blueprints from https://github.com/openmsa/Blueprints"
    echo
    echo "Options:"
    print_arg "--lic" "Force license installation"
    print_arg "-y" "Answer yes for all questions"
    print_arg "-t" "Fecth library with given tag"
    print_arg "-b" "Fecth library with given branch"
    exit 0
}

main() {
    cmd=$1

    if [[ -z "$cmd" || "$cmd" == --help ]]
    then
        usage
    fi

    shift

    while [ ! -z "$1" ]
    do
        option=$1
        case $option in
            --lic)
                INSTALL_LICENSE=true
                ;;
            -y)
                ASSUME_YES=true
                ;;
            -t)
                shift
                GTAG=$1
                emit_step "Installing libraries with tag: %b" "$GTAG"
                ;;
            -b)
                shift
                GBRANCH=$1
                emit_step "Installing libraries with branch: %b" "$GBRANCH"
                ;;
            *)
            echo "Error: unknown option: $option"
            usage
            ;;
        esac
        shift
    done
    if [[ -z "$TAG" && -z "$BRANCH" ]]
    then
        BRANCH="$GITHUB_DEFAULT_BRANCH"
    fi
    init_intall
    install_license  "$option"
    case $cmd in
        all)
            install_python_sdk
            install_php_sdk
            install_microservices
            install_workflows
            install_adapters
            ;;
        ms)
            install_microservices
            ;;
        wf|kibana_dashboard)            
            install_workflows
            ;;
        da)
            install_adapters
            ;;
        py)
            install_python_sdk
            ;;
	    php)
            install_php_sdk
            ;;
        mano)
            install_mano_workflows
            ;;
        ccla)
            install_ccla_lib
            ;;
        *)
            emit_error "Unknown command: $1"
            usage
            ;;
    esac
    finalize_install
}

main "$@"
