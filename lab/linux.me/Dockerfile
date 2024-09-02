FROM docker.io/ubiqube/ubi-almalinux9:latest

RUN dnf install -y epel-release.noarch && \
  yum clean all && \
  rm -rf /var/cache/yum

RUN yum install -y coreutils-common lsb_release openssh-server sudo iptables-services net-snmp net-snmp-utils net-snmp-libs tcpdump rsyslog dmidecode && \
  yum clean all && \
  rm -rf /var/cache/yum

RUN passwd --stdin root <<< "ubiqube"
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
#RUN echo ':msg, contains, "Time has been changed" ~ ' > /etc/rsyslog.d/time_msgs.conf
RUN echo '*.* @msa-rsyslog' > /etc/rsyslog.d/mini_lab.conf

COPY snmpd.conf /etc/snmp/
COPY docker-entrypoint.sh /

EXPOSE 161
EXPOSE 22

CMD [ "/docker-entrypoint.sh" ]
HEALTHCHECK CMD test -f /usr/bin/install_libraries.sh || echo false
