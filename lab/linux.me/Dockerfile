FROM centos:6

# for msa asset info
RUN yum install -y redhat-lsb-core dmidecode openssh-server sudo iptables

RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN chkconfig --add iptables && chkconfig iptables on
RUN chkconfig --add sshd && chkconfig sshd on

CMD [ "/sbin/init" ]
