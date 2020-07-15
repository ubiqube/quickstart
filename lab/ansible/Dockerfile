FROM centos:6.8

# 3rd party repo (EPEL) 
RUN yum -y install epel-release

# for msa asset info
RUN yum install -y redhat-lsb-core dmidecode

# for msa asset access
RUN yum install -y openssh-server openssh-clients sudo 

# Ansible
RUN yum install -y ansible

RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"
RUN echo 'msa  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN chkconfig iptables on
RUN chkconfig sshd on

CMD [ "/sbin/init" ]
