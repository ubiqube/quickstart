FROM centos:6

ENV container docker

RUN yum install -y redhat-lsb-core dmidecode openssh-server \   
        sudo iptables net-snmp net-snmp-utils tcpdump

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN echo -e "Port 22\n\
AddressFamily any\n\
ListenAddress 0.0.0.0\n\
PermitRootLogin yes\n\
PasswordAuthentication yes" >> /etc/ssh/sshd_config

COPY snmpd.conf /etc/snmp/

RUN chkconfig --add iptables && chkconfig iptables on
RUN chkconfig --add sshd && chkconfig sshd on
RUN chkconfig --add snmpd && chkconfig snmpd on

CMD [ "/sbin/init" ]
