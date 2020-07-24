FROM ubiqube/msa2-sms:a69b3ff5933ebbc15fc762c8336f95adc4a62bd9

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

#CMD [ "/sbin/init" ]
CMD ["/docker-entrypoint.sh"]
