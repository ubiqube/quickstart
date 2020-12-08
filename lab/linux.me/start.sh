#!/bin/sh
set -x
sudo iptables -I INPUT -p udp -m udp --dport 161 -j ACCEPT
sudo iptables -I INPUT -p udp -m udp --dport 162 -j ACCEPT
sudo iptables-save > /etc/sysconfig/iptables


