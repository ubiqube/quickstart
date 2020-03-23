FROM ubiqube/msa2:api-20.0

COPY create_tenant_customer.sh /usr/bin/
RUN chmod a+x  /usr/bin/create_tenant_customer.sh
RUN echo /usr/bin/create_tenant_customer.sh >> /etc/rc.local
CMD [ "/sbin/init" ]
