#!/bin/sh

# WORKAROUND FOR UNCERTAIN DOCKER INTERFACE ORDER
eth0=$(ifconfig | grep -B1 "inet addr:172.20.0." | awk '$1!="inet" && $1!="--" {print $1}')
eth1=$(ifconfig | grep -B1 "inet addr:10.222.222." | awk '$1!="inet" && $1!="--" {print $1}')
eth2=$(ifconfig | grep -B1 "inet addr:10.222.223." | awk '$1!="inet" && $1!="--" {print $1}')
eth3=$(ifconfig | grep -B1 "inet addr:10.222.224." | awk '$1!="inet" && $1!="--" {print $1}')
eth4=$(ifconfig | grep -B1 "inet addr:10.222.225." | awk '$1!="inet" && $1!="--" {print $1}')

# CONFIGURE OPENSSH
echo -e "Port 22\n\
AddressFamily any\n\
ListenAddress 0.0.0.0\n\
PermitRootLogin yes\n\
PasswordAuthentication yes" >> /etc/ssh/sshd_config

# CHANGE ROOT PASSWORD
echo root:root123 | chpasswd

# PREPARE NETWORKING
ip link set $eth1 promisc on
ip link set $eth2 promisc on
ip link set $eth3 promisc on
ip link set $eth4 promisc on

ip link add link $eth4 name $eth4.200 type vlan id 200
ip link set $eth4.200 promisc on
iplink set $eth4.200 up

brctl addbr vlan_default
brctl addif vlan_default $eth1
brctl addif vlan_default $eth2
brctl addif vlan_default $eth4
brctl addbr vlan_100
brctl addif vlan_100 $eth3
brctl addbr vlan_200
brctl addif vlan_200 $eth4.200

ifconfig vlan_default up
ifconfig vlan_100 up
ifconfig vlan_200 up

# RUN SNMPD
snmpd -C -c /etc/snmpd/snmpd.conf

# RUN SSH SERVER
/usr/sbin/sshd -D
