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
    git clone https://github.com/openmsa/Adapters.git OpenMSA_Adapters; \
    cd OpenMSA_Adapters; \
    git checkout -b msa_dev; \
  	### MS ###
    cd /opt/fmc_repository ; \
    git clone https://github.com/openmsa/Microservices.git OpenMSA_MS; \
    cd OpenMSA_MS; \
    git checkout -b msa_dev; \
 	### WF ###
    cd /opt/fmc_repository ; \
    git clone https://github.com/openmsa/Workflows.git OpenMSA_WF; \
    cd OpenMSA_WF; \
 	### Quickstart ###
    cd /opt/fmc_repository/; \
    git clone -v https://github.com/ubiqube/quickstart.git quickstart; \
    cd quickstart; \
    git checkout -b msa_dev; \
    :

 # install a custom asset script for Linux
RUN	mkdir -p /opt/sms/bin/php/polld/custom
COPY resources/opt/sms/bin/php/polld/custom/linux_generic_mgmt.php  /opt/sms/bin/php/polld/custom/

# install the lab: workflows
RUN	cd /opt/fmc_repository/Process/; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/SelfDemoSetup SelfDemoSetup; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR/.meta_SelfDemoSetup .meta_SelfDemoSetup; \
    :    
COPY resources/create_mini_lab.sh /usr/bin/
COPY resources/install_libraries.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_mini_lab.sh; \
    chmod a+x  /usr/bin/install_librairies.sh: \
    :

RUN chown -R ncuser:ncuser /opt/fmc_repository/*; \
    chown -R ncuser:ncuser /opt/fmc_repository/.meta_*; \
    chown -R ncuser:ncuser /opt/sms/bin/php/*; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
    :
# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
