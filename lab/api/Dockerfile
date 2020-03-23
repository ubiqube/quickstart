FROM ubiqube/msa2:api-20.0


RUN mkdir -p /opt/fmc_repository/Process/
RUN mkdir -p /opt/fmc_repository/CommandDefinition/

#COPY repository/Process/BLR/* /opt/fmc_repository/Process/BLR/
#COPY repository/Process/BLR/.* /opt/fmc_repository/Process/BLR/
#COPY repository/CommandDefinition/BLR/* /opt/fmc_repository/CommandDefinition/BLR/
#COPY repository/CommandDefinition/BLR/.* /opt/fmc_repository/CommandDefinition/BLR/
#RUN chown -R ncuser:ncuser /opt/fmc_repository/Process/BLR
#RUN chown -R ncuser:ncuser /opt/fmc_repository/CommandDefinition/BLR

# clean up some folder
RUN rm -rf /opt/fmc_repository/Process/Cisco_ZTD_service
RUN rm -rf /opt/fmc_repository/Process/Topology
RUN rm -rf /opt/fmc_repository/CommandDefinition/microservices



RUN	cd /opt/fmc_repository && \
    mkdir -p /opt/fmc_repository/Process/; \
    mkdir -p /opt/fmc_repository/CommandDefinition/; \
	git clone https://github.com/ubiqube/quickstart; \
    cd /opt/fmc_repository/CommandDefinition/; \
    ln -s ../../quickstart/lab/api/repository/CommandDefinition/BLR BLR; \
    ln -s ../../quickstart/lab/api/repository/CommandDefinition/.meta_BLR .meta_BLR; \
    chown -R ncuser:ncuser /opt/fmc_repository/; \
    :

RUN chown -R ncuser:ncuser /opt/fmc_repository/

COPY create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh
RUN echo /usr/bin/create_tenant_customer.sh >> /etc/rc.local

CMD [ "/sbin/init" ]
