#!/bin/bash

#set -x
USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="BLR"

/usr/bin/wait_for_api.sh
if [ $? -ne 0 ]; then
    echo "\nERROR: API unavailable"
    exit 1
fi


RESPONSE=`curl -s -H 'Content-Type: application/json' -XPOST http://msa_api:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
if [ -z "$RESPONSE" ]
then
      echo "Authentication API error"
      exit 1
fi
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")

echo "-------------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND CUSTOMER Tyrell Corporation"
echo "-------------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/operator/$OPERATOR?name=BladeRunner"
echo
curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://msa_api:8480/ubi-api-rest/customer/$OPERATOR?name=Tyrell%20Corporation&reference=TyrellCorp" -d '{"name":"Tyrell Corporation"}'
echo
CUSTLIST=`curl -s -H "Content-Type:application/json" -H "Authorization: Bearer "$TOKEN -XGET http://msa_api:8480/ubi-api-rest/lookup/customers`

IFS='"' # set delimiter
read -ra ADDR <<< "$CUSTLIST" # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do # access each element of array
    if [[ $i == BLRA* ]]  
    then  
	CUSTID=$i
    fi
done

echo $CUSTID


echo "--------------------------------------------------"
echo "ATTACH WORKFLOWS TO CUSTOMER $CUSTID"  
echo "--------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/SelfDemoSetup/SelfDemoSetup.xml"
sleep 1
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/Tutorials/python/Simple_Firewall/Simple_Firewall.xml"
sleep 1

echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"
CUSTIDONLY=${CUSTID//BLRA}
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup" \
    -d '{  "manufacturer_id": "14020601",  "password": "ubiqube",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me",  "model_id": "14020601",  "device_ip_address": "172.20.0.101",  "login": "msa", "hostname": "linux_me" }'
echo
#curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://msa_api:8480/ubi-api-rest/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup_2" -d '{"customer_id":"'$CUSTIDONLY'"}'
#echo


