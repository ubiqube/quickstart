#!/bin/sh

# WORKAROUND FOR UNCERTAIN DOCKER INTERFACE ORDER
eth0=$(ifconfig | grep -B1 "inet addr:172.20.0." | awk '$1!="inet" && $1!="--" {print $1}')
eth1=$(ifconfig | grep -B1 "inet addr:10.222." | awk '$1!="inet" && $1!="--" {print $1}')

# CHANGE IP ADDRESS TO THE PROPER ONE AND MAKE 4th MACHINE TAGGED
NUM=`echo $HOSTNAME | grep -E -o '[1-9]'`
IPADDR=`ifconfig $eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
NEW_IPADDR='10.222.222.1'$NUM'/24'

if [ $NUM = '4' ]; then
    ip a d $IPADDR dev $eth1
    ip link add link $eth1 name $eth1.200 type vlan id 200
    ip a a $NEW_IPADDR dev $eth1.200
    iplink set $eth1.200 up
else
    ip a d $IPADDR dev $eth1
    ip a a $NEW_IPADDR dev $eth1
fi

# CONFIGURE OPENSSH
echo -e "Port 22\n\
AddressFamily any\n\
ListenAddress 0.0.0.0\n\
PermitRootLogin yes\n\
PasswordAuthentication yes" >> /etc/ssh/sshd_config

# CHANGE ROOT PASSWORD
echo root:root123 | chpasswd

# RUN SNMPD
snmpd -C -c /etc/snmpd/snmpd.conf

# RUN SSH SERVER
/usr/sbin/sshd -D
