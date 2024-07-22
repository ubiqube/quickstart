#!/bin/bash

if [ $# -eq 0 ]
then
        echo -e "\033[31;1;1mERROR\033[0m"
        echo
        echo "Please provide a github URL:"
        echo -e "    Exemple for ssh \033[37;1;1mgit@github.com:openmsa\033[0m"
        echo -e "    Exemple fot https \033[37;1;1mhttps://github.com/openmsa\033[0m"
        echo
        exit 1
fi
if [ -z "$2" ]
then
        filename="${1##*/}"
        reponame=${filename%%.*}
else
        reponame=$2
fi
echo -e "Linking new repo to \033[37;1;1m$reponame\033[0m"
pushd /opt/fmc_repository
        git clone $1 $reponame
        pushd /opt/fmc_repository/Process
        ln -s ../$reponame
        popd
        install_repo_deps.sh /opt/fmc_repository/$reponame
popd
