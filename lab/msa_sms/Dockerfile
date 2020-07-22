FROM ubiqube/msa2-sms:791bdf12f7fcce28c73b40352737e54761d43ed1

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
