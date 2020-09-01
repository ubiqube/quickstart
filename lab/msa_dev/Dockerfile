FROM centos:7

RUN yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm git php openssh-server sudo
RUN yum -y upgrade git 
#ENV container docker
#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN adduser ncuser
# install some useful things
RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"; \
    git config --global push.default simple; \
    :

RUN mkdir -p /opt/devops/sms/bin/php/polld/custom/; \
    mkdir -p /opt/fmc_entities; \
    mkdir -p /opt/fmc_repository/CommandDefinition; \
    mkdir -p /opt/fmc_repository/Configuration; \
    mkdir -p /opt/fmc_repository/Datafiles; \
    mkdir -p /opt/fmc_repository/Documentation; \
    mkdir -p /opt/fmc_repository/Firmware; \
    mkdir -p /opt/fmc_repository/License; \
    mkdir -p /opt/fmc_repository/Process; \
    :

COPY --chown=ncuser:ncuser resources/opt/ /opt/

RUN cd /opt/devops/; \
    ### DA ### 
    if [ -d OpenMSA_Adapters ]; then cd OpenMSA_Adapters; git pull; else git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; fi; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/devops/OpenMSA_Adapters ; git checkout 2.2.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
 	### MS ###
    cd /opt/fmc_repository ; \
    if [ -d OpenMSA_MS ]; then  cd OpenMSA_MS; git pull; else git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; fi; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/fmc_repository/OpenMSA_MS ; git checkout 2.2.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    ### WF ###
    cd /opt/fmc_repository ; \
    if [ -d OpenMSA_WF ]; then cd OpenMSA_WF;  git pull ; else  git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; cd OpenMSA_WF; fi ; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/fmc_repository/OpenMSA_WF ; git checkout 2.2.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    ### MANO ###
    cd /opt/fmc_repository ; \
    if [ -d OpenMSA_MANO ]; then cd OpenMSA_MANO;  git pull ; else  git clone https://github.com/openmsa/etsi-mano.git OpenMSA_MANO; cd OpenMSA_MANO; fi ; \
    ### Quickstart ###
    cd /opt/fmc_repository ; \
    if [ -d /opt/fmc_repository/quickstart ]; then cd quickstart; git pull ; else git clone https://github.com/ubiqube/quickstart.git quickstart; fi ; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/fmc_repository/quickstart ; git checkout 2.2.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    :

# remove all adapter config from code base
RUN mkdir -p /opt/ubi-jentreprise/generated/conf/device/custom/;

# install the lab: workflows
RUN	cd /opt/fmc_repository/Process; \
    cp -r ../OpenMSA_WF/Reference .; \
    cp ../OpenMSA_WF/.meta_Reference .; \
    ln -fs ../quickstart/lab/msa_dev/resources/libraries/workflows/SelfDemoSetup SelfDemoSetup; \
    ln -fs ../quickstart/lab/msa_dev/resources/libraries/workflows/.meta_SelfDemoSetup .meta_SelfDemoSetup; \
    ln -fs ../OpenMSA_WF/Tutorials Tutorials; \
    ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -fs /opt/fmc_repository/OpenMSA_MS/LINUX LINUX; ln -fs ../OpenMSA_MS/.meta_LINUX .meta_LINUX; \
    :

COPY resources/scripts/create_test_me.sh /usr/bin/
COPY resources/scripts/create_mini_lab.sh /usr/bin/
COPY resources/scripts/install_libraries.sh /usr/bin/
COPY resources/scripts/install_license.sh /usr/bin/

RUN chmod a+x /usr/bin/create_mini_lab.sh; \
    chmod a+x /usr/bin/install_libraries.sh; \
    chmod a+x /usr/bin/create_test_me.sh; \
    chmod a+x /usr/bin/install_license.sh; \
    chown -R ncuser:ncuser /opt/fmc_repository/*; \
    chown -R ncuser:ncuser /opt/fmc_entities/; \
    chown -R ncuser:ncuser /opt/devops/*; \
    :

CMD ["/usr/sbin/init"]