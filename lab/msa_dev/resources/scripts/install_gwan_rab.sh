#!/bin/bash
#set -x

PROG=$(basename $0)

DEV_BRANCH=default_dev_branch
GITHUB_DEFAULT_BRANCH=master
QUICKSTART_DEFAULT_BRANCH=master
ASSUME_YES=false

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
    
    git config --global user.email devops@openmsa.co
    
	update_git_repo "https://github.com/ubiqube/nttcw-gwan-rab-ms.git" "/opt/fmc_repository" "nttcw-gwan-rab-ms" $GITHUB_DEFAULT_BRANCH "default_dev_branch"

    update_git_repo "https://github.com/ubiqube/nttcw-gwan-rab-wf.git" "/opt/fmc_repository" "nttcw-gwan-rab-wf" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
	
	update_git_repo "https://github.com/ubiqube/nttcw-gwan-rab-bpmn.git" "/opt/fmc_repository" "nttcw-gwan-rab-bpmn" $GITHUB_DEFAULT_BRANCH "default_dev_branch"
}

install_microservices () {
    
    echo "-------------------------------------------------------------------------------"
    echo " Install GWAN-RAB MS from UBiqube github repository"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/CommandDefinition/;
    echo "  >> nttcw-gwan-rab-ms"
    ln -fsn ../nttcw-gwan-rab-ms nttcw-gwan-rab-ms;
	echo ">>"
    echo "DONE"
}

install_workflows() {

	echo "-------------------------------------------------------------------------------"
    echo " Install GWAN-RAB WF from UBiqube github repository"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Process; \
    echo "  >> nttcw-gwan-rab-wf"
    ln -fsn ../nttcw-gwan-rab-wf nttcw-gwan-rab-wf; \
	echo ">>"
    echo "DONE"
}

install_bpmn() {
	
	echo "-------------------------------------------------------------------------------"
    echo " Install GWAN-RAB BPMN from UBiqube github repository"
    echo "-------------------------------------------------------------------------------"
    cd /opt/fmc_repository/Bpmn; \
    echo "  >> nttcw-gwan-rab-bpmn"
    ln -fsn ../nttcw-gwan-rab-bpmn nttcw-gwan-rab-bpmn; \
	echo ">>"
	echo "DONE"
}

finalize_install() {

    echo "-------------------------------------------------------------------------------"
    echo " update file owner to ncuser.ncuser"
    echo "-------------------------------------------------------------------------------"
    chown -R ncuser:ncuser /opt/fmc_repository/*; \
    chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
	echo ">>"
    echo "DONE"
}

usage() {
	echo "usage: $PROG all|ms|wf|bpmn"
  echo
  echo "this script installs some librairies available @github.com/openmsa"
	echo
  echo "Commands:"
	echo "all:          install everything: worflows, microservices and bpmn"
	echo "ms:           install the microservices from https://github.com/ubiqube/nttcw-gwan-rab-ms.git"
	echo "wf:           install the worflows from https://github.com/ubiqube/nttcw-gwan-rab-wf.git"
	echo "bpmn:         install the bpmn from https://github.com/ubiqube/nttcw-gwan-rab-bpmn.git"
  echo "Options:"
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
        option=$1
        case $option in
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
			update_all_github_repo
            install_microservices;
            install_workflows;
            install_bpmn;
			;;
		ms)
			update_all_github_repo
			install_microservices 
			;;
		wf)
			update_all_github_repo
			install_workflows 
			;;
		bpmn)
			install_bpmn
			;;

		*)
            echo "Error: unknown command: $1"
            usage
			;;
	esac
    finalize_install
}


main "$@"

