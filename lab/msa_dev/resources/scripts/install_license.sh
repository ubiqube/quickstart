#!/bin/bash
#set -x

# this script will upload a license file to the MSA-2 
# it takes 2 parameters:
# parameter 1 is mandatory: the path the the license file
# parameter 2, optional: the IP or FQDN of the MSActivator portal. Default is localhost
# 


PROG=$(basename $0)

USER="ncroot"
PASSWORD="ubiqube"

usage() {
	echo "usage: $PROG <license file path> [<MSActivator IP or FQDN>]"
	echo
	echo "install a license on the MSActivator."
   	echo "default FQDN: localhost"
}

if [ -z "$1" ]; then
   #get license from repository
   curl -s -k https://repository.ubiqube.com/share/license/MSA2-eval.lic --output /opt/devops/MSA2-eval.lic

   if [ $? -ne 0 ]; then
    echo "download license failed"
    exit 1
   fi
   LICENSE_PATH=/opt/devops/MSA2-eval.lic
else
    LICENSE_PATH=$1
fi

if [ -z "$2" ]; then
    MSA_IP=msa_api
else
    MSA_IP=$2
fi

RESPONSE=`curl -s -k -H 'Content-Type: application/json' -XPOST http://$MSA_IP:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
if [ -z "$RESPONSE" ]
then
      echo "Authentication API error"
      exit 1
fi
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")

curl --location -s -k -H "Authorization: Bearer "$TOKEN -XPOST http://$MSA_IP:8480/ubi-api-rest/system-admin/v1/license --form file=@$LICENSE_PATH

