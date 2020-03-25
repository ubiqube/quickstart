FROM ubiqube/msa2:api-20.0

# clean up some folder
RUN rm -rf /opt/fmc_repository/Process/Cisco_ZTD_service; \
    rm -rf /opt/fmc_repository/Process/Topology; \
    rm -rf /opt/fmc_repository/CommandDefinition/microservices; \
    :

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
    ln -s ../OpenMSA_MS/Tutorials Tutorials; ln -s ../OpenMSA_MS/.meta_Tutorials .meta_Tutorials; \
    chown -R ncuser:ncuser /opt/fmc_repository/; \
    :

COPY create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh 
RUN  echo "/usr/bin/create_tenant_customer.sh" >> /etc/rc.local 

CMD [ "/sbin/init" ]
