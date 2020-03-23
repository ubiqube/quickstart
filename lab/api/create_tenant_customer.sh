#!/bin/bash

set -x
USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="BLR"

RESPONSE=`curl -H 'Content-Type: application/json' -XPOST http://127.0.0.1/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")
echo "$TOKEN" # Use for further processsing

echo "--------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND Tyrell CUSTOMER"
echo "--------------------------------------------------"

curl -H "Content-Type: application/json" -H "Authorization: Bearer "$TOKEN -XPOST "http://127.0.0.1/ubi-api-rest/operator/$OPERATOR?name=BladeRunner"
curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/customer/$OPERATOR?name=Tyrell&reference=TyrellCorp" -d '{"name":"Tyrell"}'
curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/repository/operator?uri=Process/$OPERATOR"
curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -XPOST "http://127.0.0.1/ubi-api-rest/repository/operator?uri=CommandDefinition/$OPERATOR"

exit 0
