FROM ubiqube/msa2:api-20.0

# clean up some folder
RUN rm -rf /opt/fmc_repository/Process/Cisco_ZTD_service; \
    rm -rf /opt/fmc_repository/Process/Topology; \
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
    wget  http://demo-2.ubiqube.com/trial_license/MSA2-eval.lic; \
    cp  /opt/ubiqube/MSA2-eval.lic  /opt/ubiqube/lic/license.lic; \
    /opt/ubiqube/deploy-license.sh /opt/ubiqube/lic/license.lic /opt/ubiqube/lic/license; \
    :

# install REST Generic Adapter from github repo
RUN	cd /opt/sms/bin/php ; \
    git clone https://github.com/openmsa/Adaptors.git OpenMSA_Adapters; \
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
    rm -rf /opt/fmc_repository/CommandDefinition/BLR ;\
    rm -rf /opt/fmc_repository/CommandDefinition/.meta_BLR ; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -fs ../quickstart/lab/api/repository/CommandDefinition/BLR BLR; \
    ln -fs ../quickstart/lab/api/repository/CommandDefinition/.meta_BLR .meta_BLR; \
    rm -rf /opt/fmc_repository/Process/BLR ;\
    rm -rf /opt/fmc_repository/Process/.meta_BLR ; \
    cd /opt/fmc_repository/Process/; \
    ln -fs ../quickstart/lab/api/repository/Process/BLR BLR; \
    ln -fs ../quickstart/lab/api/repository/Process/.meta_BLR .meta_BLR; \
    chown -R ncuser:ncuser /opt/fmc_repository/; \
    :

COPY resources/create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh 

CMD [ "/sbin/init" ]
