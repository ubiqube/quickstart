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

# install Ansible lab playbook
RUN mkdir -p /opt/playbooks/
COPY resources/playbooks/linux_firewall_creation.yml /opt/playbooks/
RUN mv /etc/ansible/hosts /etc/ansible/hosts.quickstart.back
COPY resources/hosts /etc/ansible/
RUN chmod a+r /etc/ansible/hosts
RUN echo "[defaults]" >> /etc/ansible/ansible.cfg
RUN echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
CMD [ "/sbin/init" ]
