#!/bin/bash
#set -x

PROG=$(basename $0)

/usr/bin/wait_for_api.sh
if [ $? -ne 0 ]; then
    echo "\nERROR: API unavailable"
    exit 1
fi


RESPONSE=`curl -s -k -H 'Content-Type: application/json' -XPOST http://msa_api:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
if [ -z "$RESPONSE" ]
then
      echo "Authentication API error"
      exit 1
fi
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")

CUSTOMERS=`curl --location -s -k -H "Authorization: Bearer "$TOKEN -XGET http://msa_api:8480/ubi-api-rest/lookup/customers`

CUSTOMERIDS=`echo $CUSTOMERS | grep -Eo '"ubiId"[^,]*' | grep -Eo '[^:]*$' | sed 's/"//g'`

for CUSTOMER in ${CUSTOMERIDS}
do
	INSTANCES=`curl --location -s -k -H "Authorization: Bearer "$TOKEN -XGET http://msa_api:8480/ubi-api-rest/orchestration/${CUSTOMER}/service/instance`

	INSTANCEIDS=`echo $INSTANCES | grep -Eo '"id"[^,]*' | grep -Eo '[^:]*$' | sed 's/"//g'`

	for INSTANCE in ${INSTANCEIDS}
	do
		INSTANCE_DETAILS=`curl --location -s -k -H "Authorization: Bearer "$TOKEN -XGET http://msa_api:8480/ubi-api-rest/orchestration/${CUSTOMER}/service/instance/${INSTANCE}`

        INSTANCE_NAME=`echo $INSTANCE_DETAILS | grep -Eo '"name"[^,]*' | grep -Eo '[^:]*$' | sed 's/"//g'`

        if [[ $INSTANCE_NAME == *"Topology"* ]]; then

        	curl --location -s -k -H "Authorization: Bearer "$TOKEN -XDELETE http://msa_api:8480/ubi-api-rest/orchestration/v1/service/instance/${INSTANCE}
        fi
    done
done