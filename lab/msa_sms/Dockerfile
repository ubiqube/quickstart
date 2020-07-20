FROM ubiqube/msa2-sms:b18113c298e5aaa10a8653bb17b3aa16fa2d094f

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

CMD [ "/sbin/init" ]
