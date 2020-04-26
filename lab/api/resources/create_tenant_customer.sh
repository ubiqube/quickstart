#!/bin/bash

#set -x
USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="BLR"

sleep 2

RESPONSE=`curl -s -H 'Content-Type: application/json' -XPOST http://127.0.0.1/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")
#echo "$TOKEN" # Use for further processsing

echo "-------------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND CUSTOMER Tyrell Corporation"
echo "-------------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/operator/$OPERATOR?name=BladeRunner"
echo
curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/customer/$OPERATOR?name=Tyrell%20Corporation&reference=TyrellCorp" -d '{"name":"Tyrell Corporation"}'
echo
CUSTLIST=`curl -s -H "Content-Type:application/json" -H "Authorization: Bearer "$TOKEN -XGET http://127.0.0.1/ubi-api-rest/lookup/customers`

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

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/SelfDemoSetup/SelfDemoSetup.xml"
echo
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/Simple_Firewall/Simple_firewall_manager.xml"
echo
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/IMPORT/Import_microservice.xml"
sleep 2
echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"

CUSTIDONLY=${CUSTID//BLRA}

curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/orchestration/service/execute/$CUSTID/?serviceName=Process/$OPERATOR/SelfDemoSetup/SelfDemoSetup&processName=Process%2FBLR%2FSelfDemoSetup%2FProcess_Setup" -d'{"customer_id":"'$CUSTIDONLY'"}'
echo
sleep 2

#curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/repository/operator?uri=Process/$OPERATOR"
#curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/repository/operator?uri=CommandDefinition/$OPERATOR"
echo "--------------------------------------------------"
echo "CREATE SECOND CUSTOMER Rosen Corporation          "
echo "--------------------------------------------------"

curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/customer/$OPERATOR?name=Rosen%20Corporation&reference=RosenCorp" -d '{"name":"Rosen Corporation"}'
echo

