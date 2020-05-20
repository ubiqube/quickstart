FROM alpine:latest

#VOLUME [ "/sys/fs/cgroup" ]

#RUN apk add strongswan
#RUN apk add bash openssh openrc

RUN apk add openssh bash strongswan dmidecode sudo
RUN echo -e "Port 22\n\
AddressFamily any\n\
ListenAddress 0.0.0.0\n\
PermitRootLogin yes\n\
PasswordAuthentication yes" >> /etc/ssh/sshd_config

#RUN sh -c 'rc-status'

RUN echo root:root123 | chpasswd

#RUN touch /run/openrc/softlevel
#RUN sh -c 'rc-update add sshd boot'
#RUN sh -c 'rc-service sshd start'
#RUN rc-update add sshd boot
#RUN rc-service sshd restart

RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

CMD ["/usr/sbin/sshd","-D"]
