FROM ubiqube/msa2-sms:48a165db0cee78a68c923c6cb6d3f7556feeab93
#FROM yvesdumarest/msa2-sms:2.1.5

RUN rm -rf /opt/sms/devices/*

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

#CMD [ "/sbin/init" ]
CMD ["/docker-entrypoint.sh"]
