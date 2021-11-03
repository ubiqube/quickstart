#!/bin/bash

#set -x

######################################################################################
# This script is only meant to be used as a test script to create a ME for each vendor
######################################################################################

USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="TST"
OPERATOR_NAME="my_tenant"

MAN_ID=$1
MOD_ID=$2
ME_NAME=$3


RESPONSE=`curl -s -H 'Content-Type: application/json' -XPOST http://msa_api:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
if [ -z "$RESPONSE" ]
then
      echo "Authentication API error"
      exit 1
fi
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")

echo "-------------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND CUSTOMER my_subtenant"
echo "-------------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/operator/$OPERATOR?name=$OPERATOR_NAME"
echo
curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://msa_api:8480/ubi-api-rest/customer/$OPERATOR?name=my_subtenant&reference=my_subtenant" -d '{"name":"my_subtenant"}'
echo
CUSTLIST=`curl -s -H "Content-Type:application/json" -H "Authorization: Bearer "$TOKEN -XGET http://msa_api:8480/ubi-api-rest/lookup/customers`

IFS='"' # set delimiter
read -ra ADDR <<< "$CUSTLIST" # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do # access each element of array
    if [[ $i == TSTA* ]]  
    then  
	CUSTID=$i
    fi
done

echo $CUSTID


echo "--------------------------------------------------"
echo "ATTACH WORKFLOWS TO CUSTOMER $CUSTID"  
echo "--------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/SelfDemoSetup/SelfDemoSetup.xml"



echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"
CUSTIDONLY=${CUSTID//BLRA}



curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/service/execute/status/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FCreate_ME" \
    -d '{  "manufacturer_id": "14020601",  "password": "ubiqube",  "login": "msa",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me_1",  "model_id": "14020601",  "device_ip_address": "172.20.0.121", }'

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/service/execute/status/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FCreate_ME" \
    -d '{  "manufacturer_id": "14020601",  "password": "ubiqube",  "login": "msa",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me_2",  "model_id": "14020601",  "device_ip_address": "172.20.0.122", }'

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/service/execute/status/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FCreate_ME" \
    -d '{  "manufacturer_id": "14020601",  "password": "ubiqube",  "login": "msa",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me_3",  "model_id": "14020601",  "device_ip_address": "172.20.0.123", }'

