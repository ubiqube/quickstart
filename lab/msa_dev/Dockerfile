FROM centos:6.8

RUN yum -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
RUN yum install -y git 

RUN adduser ncuser

# install some useful things
RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"; \
    git config --global push.default simple; \
    :

RUN	mkdir -p /opt/fmc_repository/Process/; \
    mkdir -p /opt/fmc_repository/CommandDefinition/; \ 
    mkdir -p /opt/fmc_repository/Configuration/; \ 
    mkdir -p /opt/fmc_repository/Datafiles/; \ 
    mkdir -p /opt/fmc_repository/Firmware/; \ 
    mkdir -p /opt/fmc_repository/Documentation/; \ 
    mkdir -p /opt/fmc_repository/Pki/; \ 
    mkdir -p /opt/fmc_repository/Reports/; \ 
    :
# clean up some folder
#RUN cd /opt/fmc_repository/Process/; \
#    rm -rf /opt/fmc_repository/Process/Test_SubProcess; rm -rf /opt/fmc_repository/Process/.meta_Test_SubProcess; \
#    rm -rf /opt/fmc_repository/Process/Reference/Customer; rm -rf /opt/fmc_repository/Process/Reference/.meta_Customer; \
#    rm -rf /opt/fmc_repository/Process/Reference/Heat; rm -rf /opt/fmc_repository/Process/Reference/.meta_Heat; \
#    rm -rf /opt/fmc_repository/Process/Cisco_ZTD_service; rm -rf /opt/fmc_repository/Process/.meta_Cisco_ZTD_service; \
#    rm -rf /opt/fmc_repository/Process/Topology; rm -rf /opt/fmc_repository/Process/.meta_Topology; \
#    rm -rf /opt/fmc_repository/Process/Reference/Device_Data_File; rm -rf /opt/fmc_repository/Process/Reference/.meta_Device_Data_File; \
#    rm -rf /opt/fmc_repository/Process/Reference/Test_Autocommit; rm -rf /opt/fmc_repository/Process/Reference/.meta_Test_Autocommit; \
#    rm -rf /opt/fmc_repository/Process/Reference/Test_Rollback; rm -rf /opt/fmc_repository/Process/Reference/.meta_Test_Rollback; \
#    rm -rf /opt/fmc_repository/Process/Reference/FORTINET; rm -rf /opt/fmc_repository/Process/Reference/.meta_FORTINET; \
#    rm -rf /opt/fmc_repository/Process/Reference/PALOALTO; rm -rf /opt/fmc_repository/Process/Reference/.meta_PALOALTO; \
#    rm -rf /opt/fmc_repository/Process/Reference/VMWARE; rm -rf /opt/fmc_repository/Process/Reference/.meta_VMWARE; \
#    [[ -d /opt/fmc_repository/CommandDefinition/Reference/ ]] && mv /opt/fmc_repository/CommandDefinition/Reference/ /opt/fmc_repository/MS_Reference.bck; \
#    [[ -f /opt/fmc_repository/CommandDefinition/Reference/ ]] && mv /opt/fmc_repository/CommandDefinition/.meta_Reference /opt/fmc_repository/.meta_MS_Reference.bck; \
#    :

RUN mkdir -p /opt/sms/bin/php; \
    cd /opt/sms/bin/php ; \
    ### DA ### 
    if [ -d OpenMSA_Adapters ]; then cd OpenMSA_Adapters; git pull; else git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; fi; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/sms/bin/php/OpenMSA_Adapters ; git checkout 2.1.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
 	### MS ###
    cd /opt/fmc_repository ; \
    if [ -d OpenMSA_MS ]; then  cd OpenMSA_MS; git pull; else git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; fi; \
    ### WF ###
    cd /opt/fmc_repository ; \
    if [ -d OpenMSA_WF ]; then cd OpenMSA_WF;  git pull ; else  git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; cd OpenMSA_WF; fi ; \
    ### Quickstart ###
    cd /opt/fmc_repository ; \
    if [ -d /opt/fmc_repository/quickstart ]; then cd quickstart; git pull ; else git clone https://github.com/ubiqube/quickstart.git quickstart; fi ; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ### TODO REMOVE BEFORE PR MERGE
    cd /opt/fmc_repository/quickstart ; git checkout 2.1.0GA; \
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    :

# remove all adapter config from code base
RUN mkdir -p /opt/ubi-jentreprise/resources/templates/conf/device/custom; \
    cd /opt/ubi-jentreprise/resources/templates/conf/device/; \
    if [ -f models.properties ]; then rm -f  models.properties; fi; \
    if [ -f manufacturers.properties ]; then rm -f manufacturers.properties; fi; \
    :

 # install a custom asset script for Linux
RUN	mkdir -p /opt/sms/bin/php/polld/custom
COPY resources/opt/sms/bin/php/polld/custom/linux_generic_mgmt.php  /opt/sms/bin/php/polld/custom/

# install the lab: workflows
RUN	cd /opt/fmc_repository/Process; \
    ln -fs ../quickstart/lab/api/repository/Process/SelfDemoSetup SelfDemoSetup; \
    ln -fs ../quickstart/lab/api/repository/Process/.meta_SelfDemoSetup .meta_SelfDemoSetup; \
    ln -fs ../OpenMSA_WF/Tutorials Tutorials; \
    ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -fs /opt/fmc_repository/OpenMSA_MS/LINUX LINUX; ln -fs ../OpenMSA_MS/.meta_LINUX .meta_LINUX; \
    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/OpenMSA_Adapters/adapters/linux_generic;\
    :

COPY resources/create_test_me.sh /usr/bin/
COPY resources/create_mini_lab.sh /usr/bin/
COPY resources/install_libraries.sh /usr/bin/

RUN chmod a+x /usr/bin/create_mini_lab.sh; \
    chmod a+x /usr/bin/install_libraries.sh; \
    chmod a+x /usr/bin/create_test_me.sh; \
    chown -R ncuser:ncuser /opt/fmc_repository/*; \
    chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
    chown -R ncuser:ncuser /opt/sms/bin/php/*; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    :

# activate debug mode for SecEngine configuration
#RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
