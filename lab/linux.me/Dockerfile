FROM centos:7

ENV container docker

RUN yum install -y redhat-lsb-core openssh-server sudo iptables-services net-snmp net-snmp-utilsnet-snmp net-snmp-utils tcpdump

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers


COPY snmpd.conf /etc/snmp/

RUN systemctl enable sshd
RUN systemctl enable snmpd
RUN systemctl enable iptables
#RUN chkconfig --add iptables && chkconfig iptables on
#RUN chkconfig --add sshd && chkconfig sshd on
#RUN chkconfig --add snmpd && chkconfig snmpd on

#RUN service sshd start 
#RUN service snmpd start 

CMD [ "/sbin/init" ]
