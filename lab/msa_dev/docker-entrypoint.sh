#!/bin/bash

sudo update-ca-trust
/usr/bin/ssh-keygen -A
sudo /usr/bin/fix-perm.sh
sudo /usr/bin/init_home.sh
sudo /sbin/sshd -D -e
