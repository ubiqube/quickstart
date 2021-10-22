#!/bin/bash
#set -x

PROG=$(basename $0)

usage() {
	echo "usage: $PROG <license file path> [<MSActivator IP or FQDN>]"
	echo
	echo "install a license on the MSActivator."
   	echo "default FQDN: localhost"
}

echo "Connecting to the MSActivator API."


S="\033[s"
U="\033[u"

POS="\033[1000D\033[2C"

for (( c=1; c<=60; c++ ))
do  
    HTTP_STATUS=$(curl -m 1 --connect-timeout 1 -k -s -I -o /dev/null -w ''%{http_code}'' http://msa-api:8480/actuator/health)
    if [ $HTTP_STATUS == "200" ]
    then 
        break 2
    fi
    if [ $c == 60 ]
    then
        echo
        exit 1
    fi
    eval echo -ne '${S}${POS}\• ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\◦ ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\o ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\O ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\o ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\◦ ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\. ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\_ ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\- ${U}'
    sleep 0.2
    eval echo -ne '${S}${POS}\⌒ ${U}'
    sleep 0.2


done