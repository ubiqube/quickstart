FROM ubiqube/msa2:api-2.1.0rc1

# install some useful things
RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"
RUN git config --global push.default simple

# clean up some folder
RUN cd /opt/fmc_repository/Process/; \
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
RUN  chmod +x /opt/ubiqube/deploy-license.sh
RUN cd /opt/ubiqube/; \
    rm -f  /opt/ubiqube/*.lic  /opt/ubiqube/lic/license; \
    wget --no-check-certificate https://repository.ubiqube.com/share/license/MSA2-eval.lic; \
    cp -f /opt/ubiqube/MSA2-eval.lic  /opt/ubiqube/lic/license.lic; \
    /opt/ubiqube/deploy-license.sh /opt/ubiqube/lic/license.lic /opt/ubiqube/lic/license; \
    :

# install REST Generic Adapter from github repo
RUN	cd /opt/sms/bin/php ; \
    git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; \
    chown -R ncuser:ncuser OpenMSA_Adapters; \
    ln -s OpenMSA_Adapters/adapters/rest_generic rest_generic; \
    chown -R ncuser:ncuser rest_generic; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/rest_generic/conf; \
    cd /opt/sms/templates/devices/rest_generic/conf; \
    ln -s /opt/sms/bin/php/rest_generic/conf/sms_router.conf sms_router.conf; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    cd /opt/ubi-jentreprise/resources/templates/conf/device/; \
    mkdir custom; \
    cp manufacturers.properties custom; \
    cp models.properties custom; \
    cd /opt/sms/bin/php/OpenMSA_Adapters/bin/; \
    ./da_installer install /opt/sms/bin/php/rest_generic; \
    /opt/ubi-jentreprise/configure; \
    :

# install some MS from OpenMSA github repo
RUN	cd /opt/fmc_repository ; \
    rm -rf /opt/fmc_repository/OpenMSA_MS ; \
    git clone https://github.com/openmsa/Microservices OpenMSA_MS; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -s ../OpenMSA_MS/LINUX LINUX; ln -s ../OpenMSA_MS/.meta_LINUX .meta_LINUX; \
    ln -s ../OpenMSA_MS/REST REST; ln -s ../OpenMSA_MS/.meta_REST .meta_REST; \
#   ln -s ../OpenMSA_MS/AWS AWS; ln -s ../OpenMSA_MS/.meta_AWS .meta_AWS; \
#   ln -s ../OpenMSA_MS/CISCO CISCO; ln -s ../OpenMSA_MS/.meta_CISCO .meta_CISCO; \
#   ln -s ../OpenMSA_MS/FORTINET FORTINET; ln -s ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; \
#   ln -s ../OpenMSA_MS/PALOALTO PALOALTO; ln -s ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; \
#   ln -s ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -s ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; \
    chown -R ncuser.ncuser /opt/fmc_repository/CommandDefinition; \
    :

# install some WF from OpenMSA github repo
RUN	cd /opt/fmc_repository ; \
    rm -rf /opt/fmc_repository/OpenMSA_WF ; \
    git clone https://github.com/openmsa/Workflows OpenMSA_WF; \
    cd /opt/fmc_repository/Process/; \
    ln -fs ../OpenMSA_WF/Tutorials Tutorials ; \
    ln -fs ../OpenMSA_WF/.meta_Tutorials .meta_Tutorials; \
    chown -R ncuser.ncuser Tutorials; \
    chown -R ncuser.ncuser .meta_Tutorials; \
    :

RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/DOCKER /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_DOCKER; 
RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/ENEA /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_ENEA; 
RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/JIRA /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_JIRA; 
RUN rm -rf /opt/fmc_repository/OpenMSA_MS/REST/Generic/JUN-NORTHSTAR /opt/fmc_repository/OpenMSA_MS/REST/Generic/.meta_JUN-NORTHSTAR; 


 # install a custom asset script for Linux
RUN	mkdir -p /opt/sms/bin/php/polld/custom
COPY resources/opt/sms/bin/php/polld/custom/linux_generic_mgmt.php  /opt/sms/bin/php/polld/custom/
RUN chown -R ncuser:ncuser /opt/sms/bin/php/polld/custom


# install the lab: workflows
RUN	mkdir -p /opt/fmc_repository/Process/ 
RUN mkdir -p /opt/fmc_repository/CommandDefinition/ 

RUN git clone https://github.com/ubiqube/quickstart /opt/fmc_repository/quickstart
RUN chown -R ncuser:ncuser /opt/fmc_repository/quickstart/

RUN cd /opt/fmc_repository/Process/; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/SelfDemoSetup SelfDemoSetup; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/.meta_SelfDemoSetup .meta_SelfDemoSetup; \
    :
RUN chown -R ncuser:ncuser /opt/fmc_repository/
RUN chown -R ncuser:ncuser /opt/fmc_repository/Process/*
RUN chown -R ncuser:ncuser /opt/fmc_repository/Process/.meta_* 

COPY resources/create_mini_lab.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_mini_lab.sh 

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

RUN echo "sleep 10" >> /etc/rc.local
RUN echo "service tomcat stop" >> /etc/rc.local
RUN echo "httpd -f /opt/ses/httpd/httpd.conf -DSSL -k stop"  >> /etc/rc.local
RUN echo "sleep 10" >> /etc/rc.local
RUN echo "service ubi-ses stop" >> /etc/rc.local
RUN chkconfig tomcat off 

###### ADDITIONAL CUSTO ########
# install REDFISH MS/WF/DA from OpenMSA github repo
RUN	cd /opt/fmc_repository/CommandDefinition ; \
    ln -s ../OpenMSA_MS/REDFISHAPI REDFISHAPI; ln -s ../OpenMSA_MS/.meta_REDFISHAPI .meta_REDFISHAPI; \
    chown -R ncuser.ncuser /opt/fmc_repository/CommandDefinition/REDFISHAPI/; \
    cd /opt/fmc_repository/Process/; \
    ln -fs ../OpenMSA_WF/BIOS_Automation BIOS_Automation; \
    ln -fs ../OpenMSA_WF/.meta_BIOS_Automation .meta_BIOS_Automation; \
    chown -R ncuser.ncuser BIOS_Automation; \
    chown -R ncuser.ncuser .meta_BIOS_Automation; \
    cd /opt/sms/bin/php ; \
    ln -fs OpenMSA_Adapters/adapters/redfish_generic redfish_generic; \
    chown -R ncuser:ncuser redfish_generic; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/redfish_generic/conf; \
    cd /opt/sms/templates/devices/redfish_generic/conf; \
    ln -s /opt/sms/bin/php/redfish_generic/conf/sms_router.conf sms_router.conf; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    mkdir -p /opt/ubi-jentreprise/resources/templates/conf/device/custom; \
    /opt/sms/bin/php/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/redfish_generic; \
    /opt/ubi-jentreprise/configure; \
    :

# install ONEACCESS MS from OpenMSA github repo
RUN	cd /opt/fmc_repository/CommandDefinition ; \
    ln -s ../OpenMSA_MS/ONEACCESS ONEACCESS; ln -s ../OpenMSA_MS/.meta_ONEACCESS .meta_ONEACCESS; \
    chown -R ncuser.ncuser /opt/fmc_repository/CommandDefinition/ONEACCESS/; \
    :

CMD [ "/sbin/init" ]
