#!/bin/bash

#set -x
USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="TST"
OPERATOR_NAME="my_tenant"

MAN_ID=$1
MOD_ID=$2
ME_NAME=$3


RESPONSE=`curl -s -H 'Content-Type: application/json' -XPOST http://127.0.0.1/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")

echo "-------------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND CUSTOMER Tyrell Corporation"
echo "-------------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/operator/$OPERATOR?name=$OPERATOR_NAME"
echo
curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/customer/$OPERATOR?name=my_subtenant&reference=my_subtenant" -d '{"name":"my_subtenant"}'
echo
CUSTLIST=`curl -s -H "Content-Type:application/json" -H "Authorization: Bearer "$TOKEN -XGET http://127.0.0.1/ubi-api-rest/lookup/customers`

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

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/SelfDemoSetup/SelfDemoSetup.xml"



echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"
CUSTIDONLY=${CUSTID//BLRA}

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup" \
    -d '{  "manufacturer_id": "200425",  "password": "ubiqube",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "pfsense",  "model_id": "200425",  "device_ip_address": "192.168.1.1",  "login": "msa", }'

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup" \
    -d '{  "manufacturer_id": "18082900",  "password": "ubiqube",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "checkpoint_R80",  "model_id": "18082900",  "device_ip_address": "192.168.1.1",  "login": "msa", }'



echo
