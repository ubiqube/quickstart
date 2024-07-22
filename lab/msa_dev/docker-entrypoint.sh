#!/bin/bash

init_cloudclapp() {
    DATAFILES_DIR='/opt/fmc_repository/Datafiles/'
    # Skip the installation if the initial setup has not been done. (= folders under fmc_repository are not created.)
    if [ -d $DATAFILES_DIR ]; then
        CCLA_WORKSPACE='/opt/fmc_repository/Datafiles/CCLA/'
        if [ ! -d $CCLA_WORKSPACE ]; then
            echo "Creating workspace directory for Cloudclapp..."
            mkdir $CCLA_WORKSPACE
            chown ncuser. $CCLA_WORKSPACE
        fi

        DASHBOARD_DIR='/opt/fmc_repository/Datafiles/ccla_dashboard/'
        if [ ! -d $DASHBOARD_DIR ]; then
            echo "Creating dashboard directory for Cloudclapp..."
            mkdir $DASHBOARD_DIR
            chown ncuser. $DASHBOARD_DIR
        fi

        KUBE_PROMETHEUS_DIR='/opt/fmc_repository/Datafiles/CCLA/kube-prometheus'
        if [ ! -d $KUBE_PROMETHEUS_DIR ]; then
            KUBE_PROMETHEUS_REPO=https://github.com/prometheus-operator/kube-prometheus.git
            echo "Setting up Prometheus manifest for Cloudclapp..."
            # Check Internet connectivity and repository existence
            if timeout 15s git ls-remote $KUBE_PROMETHEUS_REPO -q ; then
                git clone $KUBE_PROMETHEUS_REPO $KUBE_PROMETHEUS_DIR
                git -C $KUBE_PROMETHEUS_DIR checkout release-0.8
                chown -R ncuser. $KUBE_PROMETHEUS_DIR
            else
                echo "Failed to get manifests. Check your Internet connectivity."
            fi
        fi
    fi
}

if [[ "$1" == --cloudclapp ]]; then
    init_cloudclapp
fi
sudo update-ca-trust
/usr/bin/ssh-keygen -A
sudo /usr/bin/fix-perm.sh
sudo /usr/bin/init_home.sh
sudo /sbin/sshd -D -e

