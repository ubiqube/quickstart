#!/bin/bash

# initialize sms configuration
# should be started before systemd in order to have template files resolved
/usr/bin/ssh-keygen -A

/usr/sbin/snmpd
/usr/sbin/rsyslogd
exec /sbin/sshd -D -e
