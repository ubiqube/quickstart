FROM centos:7

RUN yum install -y redhat-lsb-core openssh-server sudo iptables-services net-snmp net-snmp-utilsnet-snmp net-snmp-utils tcpdump

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers


COPY snmpd.conf /etc/snmp/

RUN systemctl enable sshd
RUN systemctl enable snmpd
RUN systemctl enable iptables
USER root

RUN mkdir /start
COPY ./start.sh /start
RUN ["chmod", "+x", "/start/start.sh"]
RUN /start/start.sh

CMD [ "/sbin/init" ]
