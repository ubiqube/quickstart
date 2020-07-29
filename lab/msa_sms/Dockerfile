FROM ubiqube/msa2-sms:2466c3e1ebe4399ec6f3006fc56b7846c673eed2

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

#CMD [ "/sbin/init" ]
CMD ["/docker-entrypoint.sh"]
