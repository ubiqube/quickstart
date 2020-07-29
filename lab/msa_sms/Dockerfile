FROM ubiqube/msa2-sms:3e32150a5202db71211d2bd453af883894c52513

# activate debug mode for SecEngine configuration
RUN sed -i -e 's/$UBI_VSOC_DEBUG_LEVEL/15/g' /opt/sms/templates/conf/smsd.conf 

#CMD [ "/sbin/init" ]
CMD ["/docker-entrypoint.sh"]
