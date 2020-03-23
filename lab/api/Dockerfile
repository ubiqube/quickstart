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


COPY create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh 
RUN  echo /usr/bin/create_tenant_customer.sh >> /etc/rc.local 

CMD [ "/sbin/init" ]
