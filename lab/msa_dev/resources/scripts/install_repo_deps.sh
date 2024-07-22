#!/bin/bash

if [ $# -eq 0 ]
then
        echo -e "\033[31;1;1mERROR\033[0m"
        echo
        echo "Please provide a path."
        exit 1
fi
REPO_TARGET=$1

echo -e "\033[29;1;1mInstalling dependencies for $REPO_TARGET ...\033[0m"

if [ -f "$REPO_TARGET/install.sh" ]; then
        $REPO_TARGET/install.sh
fi
if [ -f "$REPO_TARGET/requirements.txt" ]; then
        pip3 install -r $REPO_TARGET/requirements.txt --target /opt/fmc_repository/Process/PythonReference/
fi
if [ -f "$REPO_TARGET/setup.py" ]; then
        pushd $REPO_TARGET
        python3 setup.py -q install  --install-lib='/opt/fmc_repository/Process/PythonReference'
        popd
fi

