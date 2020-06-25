FROM ubiqube/msa2:api-2.1.0rc1

# install some useful things
RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"; \
    git config --global push.default simple; \
    :

RUN	mkdir -p /opt/fmc_repository/Process/; \
    mkdir -p /opt/fmc_repository/CommandDefinition/; \ 
    :
# clean up some folder
RUN cd /opt/fmc_repository/Process/; \
    rm -rf /opt/fmc_repository/Voiplocalization; \
    rm -rf /opt/fmc_repository/Ticketing; \
    rm -rf /opt/fmc_repository/Process/Test_SubProcess; rm -rf /opt/fmc_repository/Process/.meta_Test_SubProcess; \
    rm -rf /opt/fmc_repository/Process/Reference/Customer; rm -rf /opt/fmc_repository/Process/Reference/.meta_Customer; \
    rm -rf /opt/fmc_repository/Process/Reference/Heat; rm -rf /opt/fmc_repository/Process/Reference/.meta_Heat; \
    rm -rf /opt/fmc_repository/Process/Cisco_ZTD_service; rm -rf /opt/fmc_repository/Process/.meta_Cisco_ZTD_service; \
    rm -rf /opt/fmc_repository/Process/Topology; rm -rf /opt/fmc_repository/Process/.meta_Topology; \
    rm -rf /opt/fmc_repository/Process/Reference/Device_Data_File; rm -rf /opt/fmc_repository/Process/Reference/.meta_Device_Data_File; \
    rm -rf /opt/fmc_repository/Process/Reference/Test_Autocommit; rm -rf /opt/fmc_repository/Process/Reference/.meta_Test_Autocommit; \
    rm -rf /opt/fmc_repository/Process/Reference/Test_Rollback; rm -rf /opt/fmc_repository/Process/Reference/.meta_Test_Rollback; \
    rm -rf /opt/fmc_repository/Process/Reference/FORTINET; rm -rf /opt/fmc_repository/Process/Reference/.meta_FORTINET; \
    rm -rf /opt/fmc_repository/Process/Reference/PALOALTO; rm -rf /opt/fmc_repository/Process/Reference/.meta_PALOALTO; \
    rm -rf /opt/fmc_repository/Process/Reference/VMWARE; rm -rf /opt/fmc_repository/Process/Reference/.meta_VMWARE; \
    mv /opt/fmc_repository/CommandDefinition/Reference/ /opt/fmc_repository/MS_Reference.bck; \
    mv /opt/fmc_repository/CommandDefinition/.meta_Reference /opt/fmc_repository/.meta_MS_Reference.bck; \
    :

# install a trial license
COPY resources/deploy-license.sh /opt/ubiqube/
RUN chmod +x /opt/ubiqube/deploy-license.sh; \
    cd /opt/ubiqube/; \
    rm -f  /opt/ubiqube/*.lic  /opt/ubiqube/lic/license; \
    wget -q --no-check-certificate https://repository.ubiqube.com/share/license/MSA2-eval.lic; \
    cp -f /opt/ubiqube/MSA2-eval.lic  /opt/ubiqube/lic/license.lic; \
    /opt/ubiqube/deploy-license.sh /opt/ubiqube/lic/license.lic /opt/ubiqube/lic/license; \
    :


# install the github repositories
RUN cd /opt/sms/bin/php ; \
    ls -la; \
 	### DA ###
    if [ -d OpenMSA_Adapters ]; then cd OpenMSA_Adapters; git checkout conf/models.properties; git pull; cd -; else git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; fi ;\
  	### MS ###
    cd /opt/fmc_repository ; \
    ls -la; \
    if [ -d OpenMSA_MS ]; \
    then \ 
      cd OpenMSA_MS; git checkout master; git pull; cd -; \
    else \
      git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; \
    fi ;\
 	### WF ###
    ls -la; \
    if [ -d OpenMSA_WF ]; then cd OpenMSA_WF; git checkout master; git pull; cd -; else git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; fi ; \
 	### Quickstart ###
    ls -la; \
    if [ -d /opt/fmc_repository/quickstart ]; then echo "toto"; cd /opt/fmc_repository/quickstart; git checkout -v master; git pull; cd -; else cd /opt/fmc_repository/; git clone -v https://github.com/ubiqube/quickstart.git quickstart; fi ;\
    :

# install REST Generic Adapter from github repo
RUN cd /opt/sms/bin/php ; \
    ls -la; \
    ln -fs OpenMSA_Adapters/adapters/rest_generic rest_generic; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/rest_generic/conf; \
    cd /opt/sms/templates/devices/rest_generic/conf; \
    ln -fs /opt/sms/bin/php/rest_generic/conf/sms_router.conf sms_router.conf; \
    :
# install Netconf Generic Adapter Adapter from github repo to add the netconf da bugfixes from Openmsa github
RUN cd /opt/sms/bin/php ; \
    rm -rf netconf_generic;\
    ln -fs OpenMSA_Adapters/adapters/netconf_generic netconf_generic; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/netconf_generic/conf; \
    cd /opt/sms/templates/devices/netconf_generic/conf; \
    rm -f sms_router.conf; \
    ln -s /opt/sms/bin/php/netconf_generic/conf/sms_router.conf sms_router.conf; \
    :
# install OneAccess Netconf Adapter from github repo to add the sms_router.conf file for the new model id for OneAccess-Netconf
RUN cd /opt/sms/bin/php ; \
    rm -rf oneaccess_lbb;\
    ln -fs OpenMSA_Adapters/adapters/oneaccess_lbb oneaccess_lbb; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/oneaccess_lbb/conf; \
    cd /opt/sms/templates/devices/oneaccess_lbb/conf; \
    rm -f sms_router.conf;\
    ln -s /opt/sms/bin/php/oneaccess_lbb/conf/sms_router.conf sms_router.conf; \
    :

# Configure properties files from openmsa github repo into custom folder
RUN cd /opt/ubi-jentreprise/resources/templates/conf/device/; \
    mkdir -p /opt/ubi-jentreprise/resources/templates/conf/device/custom; \
#Using properties file from OpenMSA github for the custom versions
    rm -f /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;\
    ln -fs /opt/sms/bin/php/OpenMSA_Adapters/conf/models.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/models.properties;\
    rm -f /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;\
    cp /opt/sms/bin/php/OpenMSA_Adapters/conf/sdExtendedInfo.properties /opt/ses/properties/specifics/server_ALL/sdExtendedInfo.properties;\
    cp /opt/ubi-jentreprise/resources/templates/conf/device/manufacturers.properties /opt/ubi-jentreprise/resources/templates/conf/device/custom/; \
    /opt/sms/bin/php/OpenMSA_Adapters/bin//da_installer install /opt/sms/bin/php/rest_generic; \
    /opt/ubi-jentreprise/configure; \
    :

# install some MS from OpenMSA github repo
RUN	ls -la /opt/fmc_repository; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -s ../OpenMSA_MS/ADVA ADVA; ln -s ../OpenMSA_MS/.meta_ADVA .meta_ADVA; \
    ln -s ../OpenMSA_MS/AWS AWS; ln -s ../OpenMSA_MS/.meta_AWS .meta_AWS; \
    ln -s ../OpenMSA_MS/CISCO CISCO; ln -s ../OpenMSA_MS/.meta_CISCO .meta_CISCO; \
    ln -s ../OpenMSA_MS/FORTINET FORTINET; ln -s ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; \
    ln -s ../OpenMSA_MS/LINUX LINUX; ln -s ../OpenMSA_MS/.meta_LINUX .meta_LINUX; \
    ln -s ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -s ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; \
    ln -s ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -s ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; \
    ln -s ../OpenMSA_MS/PALOALTO PALOALTO; ln -s ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; \
    ln -s ../OpenMSA_MS/REST REST; ln -s ../OpenMSA_MS/.meta_REST .meta_REST; \
    :

# install some WF from OpenMSA github repo
RUN	cd /opt/fmc_repository/Process/; \
    ln -fs ../OpenMSA_WF/Tutorials Tutorials ; \
    ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; \
    :

#RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/DOCKER /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_DOCKER; 
#RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/ENEA /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_ENEA; 
#RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/JIRA /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_JIRA; 
#RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/JUN-NORTHSTAR /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_JUN-NORTHSTAR; 
# Removing MS defintions containing advanced variable types
RUN rm -rf /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/Advanced /opt/fmc_repository/OpenMSA_MS/ONEACCESS/Netconf/.meta_Advanced

 # install a custom asset script for Linux
RUN	mkdir -p /opt/sms/bin/php/polld/custom
COPY resources/opt/sms/bin/php/polld/custom/linux_generic_mgmt.php  /opt/sms/bin/php/polld/custom/

# install the lab: workflows
RUN	cd /opt/fmc_repository/Process/; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/SelfDemoSetup SelfDemoSetup; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/.meta_SelfDemoSetup .meta_SelfDemoSetup; \
    :    
COPY resources/create_mini_lab.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_mini_lab.sh 

 #   chown -R ncuser:ncuser /opt/fmc_repository/Process/*; \
 #   chown -R ncuser:ncuser /opt/fmc_repository/Process/.meta_* ; \
 #   chown -R ncuser:ncuser /opt/fmc_repository/quickstart/; \
 #   chown -R ncuser.ncuser /opt/fmc_repository/OpenMSA_WF/Tutorials; \
 #   chown -R ncuser.ncuser /opt/fmc_repository/OpenMSA_WF/.meta_Tutorials; \
 #   chown -R ncuser.ncuser /opt/fmc_repository/CommandDefinition/*; \
 #   chown -R ncuser.ncuser /opt/fmc_repository/CommandDefinition/.meta_*; \

RUN chown -R ncuser:ncuser /opt/fmc_repository/*; \
    chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
    chown -R ncuser:ncuser /opt/sms/bin/php/*; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
    :
# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
