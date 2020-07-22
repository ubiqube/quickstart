FROM ubiqube/msa2-sms:a528cab6ba8ffca7c64cfff329d59fab148a0c59
#FROM yvesdumarest/msa2-sms:2.1.5

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
