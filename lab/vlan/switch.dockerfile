FROM alpine:3.12

RUN mkdir /start
RUN mkdir /etc/snmpd/
WORKDIR /start
COPY ./switch.sh /start
COPY ./port /root
COPY ./snmpd.conf /etc/snmpd/snmpd.conf

RUN apk add --no-cache openssh bash net-snmp tcpdump

RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

RUN ["chmod", "+x", "/root/port"]
RUN ["chmod", "+x", "/start/switch.sh"]
ENTRYPOINT ["/start/switch.sh"]
