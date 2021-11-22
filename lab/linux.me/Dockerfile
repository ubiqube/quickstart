FROM centos:7

RUN yum install -y redhat-lsb-core openssh-server sudo iptables-services net-snmp net-snmp-utils tcpdump rsyslog

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
#RUN echo ':msg, contains, "Time has been changed" ~ ' > /etc/rsyslog.d/time_msgs.conf
RUN echo '*.* @msa_front' > /etc/rsyslog.d/mini_lab.conf
RUN mkdir -p /config/cisco_nx-os
COPY resources/config/cisco_nx-os/* /config/cisco_nx-os/
COPY snmpd.conf /etc/snmp/
RUN systemctl enable sshd
RUN systemctl enable snmpd
CMD [ "/sbin/init" ]