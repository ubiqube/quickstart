FROM ubiqube/msa2:api-20.0

# install some useful things
RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"
RUN git config --global push.default simple

# clean up some folder
RUN cd /opt/fmc_repository/Process/; \
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
# # install gradle
# RUN cd /root; \
#     curl -s "https://get.sdkman.io" | bash; \
#     source "/root/.sdkman/bin/sdkman-init.sh"; \
#     sdk install gradle 6.3; \
#     :

# install a trial license
COPY resources/deploy-license.sh /opt/ubiqube/
RUN  chmod +x /opt/ubiqube/deploy-license.sh
RUN cd /opt/ubiqube/; \
    rm -f  /opt/ubiqube/*.lic  /opt/ubiqube/lic/license; \
    wget  http://demo-2.ubiqube.com/trial_license/MSA2-eval.lic; \
    cp -f /opt/ubiqube/MSA2-eval.lic  /opt/ubiqube/lic/license.lic; \
    /opt/ubiqube/deploy-license.sh /opt/ubiqube/lic/license.lic /opt/ubiqube/lic/license; \
    :

# install REST Generic Adapter from github repo
RUN	cd /opt/settings/ ; \
    git clone https://github.com/openmsa/Adaptors.git OpenMSA_Adapters; \
    cd /opt/sms/templates/devices/; \
    mkdir -p /opt/sms/templates/devices/rest_generic/conf; \
    cd /opt/sms/templates/devices/rest_generic/conf; \
    ln -s /opt/settings/OpenMSA_Adapters/adapters/rest_generic/conf/sms_router.conf sms_router.conf; \
    chown -R ncuser:ncuser /opt/sms/templates/devices/; \
    cd /opt/sms/bin/php/; \
    ln -fs /opt/settings/OpenMSA_Adapters/adapters/rest_generic rest_generic; \
    /opt/settings/OpenMSA_Adapters/bin/da_installer install /opt/sms/bin/php/rest_generic; \
    chown -R ncuser:ncuser /opt/sms/bin/php/rest_generic; 

RUN mkdir -p /opt/settings/jentreprise/custom; \
    chown -R ncuser:ncuser /opt/settings/jentreprise; \
    cp /opt/ubi-jentreprise/resources/templates/conf/device/*.properties /opt/settings/jentreprise/custom/; \
    #ls -la /opt/settings/jentreprise/custom/; \
    cd /opt/ubi-jentreprise/resources/templates/conf/device/; \
    ln -fs /opt/settings/jentreprise/custom custom; \
    #ls -l /opt/ubi-jentreprise/resources/templates/conf/device/custom/; \
    chown -R ncuser:ncuser /opt/ubi-jentreprise/resources/templates/conf/device;\
    /opt/ubi-jentreprise/configure; \
    :

# install some MS from OpenMSA github repo
RUN	cd /opt/fmc_repository ; \
    rm -rf /opt/fmc_repository/OpenMSA_MS ; \
    git clone https://github.com/openmsa/Microservices OpenMSA_MS; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -s ../OpenMSA_MS/AWS AWS; ln -s ../OpenMSA_MS/.meta_AWS .meta_AWS; \
    ln -s ../OpenMSA_MS/LINUX LINUX; ln -s ../OpenMSA_MS/.meta_LINUX .meta_LINUX; \
    ln -s ../OpenMSA_MS/CISCO CISCO; ln -s ../OpenMSA_MS/.meta_CISCO .meta_CISCO; \
    ln -s ../OpenMSA_MS/FORTINET FORTINET; ln -s ../OpenMSA_MS/.meta_FORTINET .meta_FORTINET; \
    ln -s ../OpenMSA_MS/PALOALTO PALOALTO; ln -s ../OpenMSA_MS/.meta_PALOALTO .meta_PALOALTO; \
    ln -s ../OpenMSA_MS/OPENSTACK OPENSTACK; ln -s ../OpenMSA_MS/.meta_OPENSTACK .meta_OPENSTACK; \
    ln -s ../OpenMSA_MS/REST REST; ln -s ../OpenMSA_MS/.meta_REST .meta_REST; \
    :

# # deploy the doc from https://github.com/ubiqube
# RUN cd /root; \
#     git clone https://github.com/ubiqube/docs.git  gh.ubi.docs; \
#     cd gh.ubi.docs; \
#     ln -fs /opt/ses/share/htdocs/ publish.dir; \
#     /root/.sdkman/candidates/gradle/current/bin/gradle asciidoc; \
#     tar c build | tar x -C publish.dir; \
#     :

# install the lab: workflows
RUN	cd /opt/fmc_repository ; \
    mkdir -p /opt/fmc_repository/Process/ ; \
    mkdir -p /opt/fmc_repository/CommandDefinition/ ; \
    rm -rf /opt/fmc_repository/quickstart ; \
    git clone https://github.com/ubiqube/quickstart; \
#    rm -rf /opt/fmc_repository/CommandDefinition/BLR ;\
#    rm -rf /opt/fmc_repository/CommandDefinition/.meta_BLR ; \
#    cd /opt/fmc_repository/CommandDefinition/; \
#    ln -fs ../quickstart/lab/api/repository/CommandDefinition/BLR BLR; \
#    ln -fs ../quickstart/lab/api/repository/CommandDefinition/.meta_BLR .meta_BLR; \
#    rm -rf /opt/fmc_repository/Process/BLR ;\
#    rm -rf /opt/fmc_repository/Process/.meta_BLR ; \
    cd /opt/fmc_repository/Process/; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR BLR; \
    ln -fs ../quickstart/lab/api/repository/Process/.meta_BLR .meta_BLR; \
    chown -R ncuser:ncuser /opt/fmc_repository/; \
    :

COPY resources/create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh 

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
