FROM centos:6.8

# for msa asset info
RUN yum install -y redhat-lsb-core dmidecode

# for msa asset access
RUN yum install -y openssh-server sudo 
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN chkconfig iptables on
RUN chkconfig sshd on

CMD [ "/sbin/init" ]
