FROM alpine:3.12

RUN mkdir /start
WORKDIR /start

COPY ./pc.sh /start
COPY ./snmpd.conf /etc/snmpd/snmpd.conf

RUN apk add --no-cache openssh bash net-snmp

RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

RUN ["chmod", "+x", "/start/pc.sh"]
ENTRYPOINT ["/start/pc.sh"]
