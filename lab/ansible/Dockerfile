FROM centos:6.8 as ansible_me

# 3rd party repo (EPEL) , ansible, SSH,...
RUN yum install -y epel-release 
RUN yum install -y redhat-lsb-core dmidecode openssh-server openssh-clients sudo ansible python-pip
RUN pip install shyaml
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
