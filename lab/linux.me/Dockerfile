FROM centos:6

ENV container docker

RUN yum install -y redhat-lsb-core openssh-server  sudo iptables net-snmp net-snmp-utils tcpdump

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers


COPY snmpd.conf /etc/snmp/

RUN chkconfig --add iptables && chkconfig iptables on
RUN chkconfig --add sshd && chkconfig sshd on
RUN chkconfig --add snmpd && chkconfig snmpd on

RUN service sshd start 
RUN service snmpd start 

CMD [ "/sbin/init" ]
