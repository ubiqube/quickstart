#!/bin/bash
#set -x
USER="ncroot"
PASSWORD="ubiqube"
OPERATOR="BLR"
function executeCurl(){
        token=$1
        method=$2
        apiPath=$3
        body=$4
        echo "Token $token"
        echo "Method $method"
        echo "apiPath $apiPath"
        echo "body $body"
        res=`curl -s -H "Content-Type: application/json" -H "Authorization: Bearer "$token -X $method "http://msa-api:8480/ubi-api-rest$apiPath" -d "$body"`
        echo $res
}
/usr/bin/wait_for_api.sh
if [ $? -ne 0 ]; then
    echo "\nERROR: API unavailable"
    exit 1
fi
RESPONSE=`curl -s -H 'Content-Type: application/json' -XPOST http://msa-api:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
if [ -z "$RESPONSE" ]
then
      echo "Authentication API error"
      exit 1
fi
TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")
echo "-------------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND CUSTOMER Tyrell Corporation"
echo "-------------------------------------------------------"
tenantExist=$(executeCurl $TOKEN 'GET' "/operator/v1/exists/$OPERATOR")
if [[ $tenantExist == *"false"* ]]; then
        tenant=$(executeCurl $TOKEN 'POST' "/operator/$OPERATOR?name=BladeRunner")
else
        echo "$OPERATOR already exists"
fi
subTenantExist=$(executeCurl $TOKEN 'GET' "/customer/reference/TyrellCorp")
if [[ $subTenantExist == *"actorId"* ]]; then
        echo "Subtenant Tyrell Corporation already exists"
else
        subtenant=$(executeCurl $TOKEN 'POST' "/customer/$OPERATOR?name=Tyrell%20Corporation&reference=TyrellCorp" '{"name":"Tyrell Corporation"}')
fi
CUSTLIST=`curl -s -H "Content-Type:application/json" -H "Authorization: Bearer "$TOKEN -XGET http://msa-api:8480/ubi-api-rest/lookup/customers`
IFS='"' # set delimiter
read -ra ADDR <<< "$CUSTLIST" # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do # access each element of array
    if [[ $i == BLRA* ]]
    then
        CUSTID=$i
    fi
done
echo "Subtenant ID $CUSTID"
echo "--------------------------------------------------"
echo "ATTACH WORKFLOWS TO CUSTOMER $CUSTID"
echo "--------------------------------------------------"
echo "> Self Demo Setup"
wf=$(executeCurl $TOKEN 'POST' "/orchestration/$CUSTID/service/attach?uri=Process/SelfDemoSetup/SelfDemoSetup.xml")
echo "> Simple Firewall Python"
wf=$(executeCurl $TOKEN 'POST' "/orchestration/$CUSTID/service/attach?uri=Process/Tutorials/python/Simple_Firewall/Simple_Firewall.xml")
echo "> Security Event Detection"
wf=$(executeCurl $TOKEN 'POST' "/orchestration/$CUSTID/service/attach?uri=Process/Tutorials/alarm/Alarm_Action/Alarm_Action.xml")
echo "> Dashboard Deployment"
wf=$(executeCurl $TOKEN 'POST' "/orchestration/$CUSTID/service/attach?uri=Process/Analytics/Kibana/kibana_dashboard.xml")
echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"
CUSTIDONLY=${CUSTID//BLRA}
PID1RAW=$(executeCurl $TOKEN 'POST' "/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup" '{"manufacturer_id": "14020601",  "password": "ubiqube",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me",  "model_id": "14020601",  "device_ip_address": "172.20.0.101",  "login": "msa", "hostname": "linux_me"}')
sleep 1
PID2RAW=$(executeCurl $TOKEN 'POST' "/orchestration/service/execute/$CUSTID/?serviceName=Process/SelfDemoSetup/SelfDemoSetup&processName=Process%2FSelfDemoSetup%2FProcess_Setup" '{"manufacturer_id": "14020601",  "password": "ubiqube",  "snmpCommunity": "ubiqube",  "password_admin": "aaaa",  "managementInterface": "eth0",  "managed_device_name": "linux_me_2",  "model_id": "14020601",  "device_ip_address": "172.20.0.102",  "login": "msa", "hostname": "linux_me_2" }')
reg='processInstanceId\s?:([0-9]+),'
[[ $PID1RAW =~ $reg ]]
PID_1=${BASH_REMATCH[1]}
[[ $PID2RAW =~ $reg ]]
PID_2=${BASH_REMATCH[1]}
#echo "PIDS : $PID_1, $PID_2"
sleep 5
ME1RAW=$(executeCurl $TOKEN 'GET' "/orchestration/v1/process-instance/$PID_1")
ME2RAW=$(executeCurl $TOKEN 'GET' "/orchestration/v1/process-instance/$PID_2")

reg='entites.exceptions.MAX_SITE_REACHED'
if [[ $ME1RAW =~ $reg ]];then
        echo "Warning : Not possible to create managed entities. Please check your license"
        exit 1
fi

reg='.*(BLR[0-9]+)'
[[ $ME1RAW =~ $reg ]]
ME1ID=${BASH_REMATCH[1]}
[[ $ME2RAW =~ $reg ]]
ME2ID=${BASH_REMATCH[1]}
echo "ME IDS : $ME1ID , $ME2ID"
echo "-----------------------------------------------------"
echo "CREATE MONITORING PROFILE AND ATTACH MANAGED ENTITIES"
echo "-----------------------------------------------------"
pflExist=$(executeCurl $TOKEN 'POST' "/profile/v1/exist/TyrellMonitoringPfl")
if [[ $pflExist == *"false"* ]]; then
        pfl=$(executeCurl $TOKEN 'POST' "/profile/monitoring-profile/$CUSTIDONLY" '{"name":"Linux","externalReference": "TyrellMonitoringPfl","comment":"TyrellMonitoringPfl","graphRendererList":[{"id":0,"profileId":0,"name":"CPU","verticalLabel":"Percent","dataList":[{"horizontalLabel":"1 min","color":"#d33115","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":0},{"horizontalLabel":"5 min","color":"#dbdf00","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":1},{"horizontalLabel":"15 min","color":"#16a5a5","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":2}]},{"id":1,"profileId":0,"name":"Memory","verticalLabel":"kB","dataList":[{"horizontalLabel":"avail","color":"#fe9200","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":3},{"horizontalLabel":"totall free","color":"#dbdf00","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":4},{"horizontalLabel":"shared","color":"#68ccca","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":5},{"horizontalLabel":"buffer","color":"#aea1ff","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":6},{"horizontalLabel":"cached","color":"#fa28ff","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":7},{"horizontalLabel":"total real","color":"#653294","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":8}]},{"id":2,"profileId":0,"name":"Traffic","verticalLabel":"KPS","dataList":[{"horizontalLabel":"IN","color":"#68ccca","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":9},{"horizontalLabel":"OUT","color":"#fcdc00","profileId":0,"rendererId":0,"snmpPollingData":null,"snmpPollingId":10}]}],"snmpPollingList":[{"id":0,"name":"cpu_load_1min","oid":"1.3.6.1.4.1.2021.10.1.5.1","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"G","threshold":60,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":1,"name":"cpu_load_5min","oid":"1.3.6.1.4.1.2021.10.1.5.2","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"G","threshold":70,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":2,"name":"cpu_load_15min","oid":"1.3.6.1.4.1.2021.10.1.5.3","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"G","threshold":80,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":3,"name":"memAvailReal","oid":".1.3.6.1.4.1.2021.4.6.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":4,"name":"memTotalFree","oid":".1.3.6.1.4.1.2021.4.11.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":5,"name":"memShared","oid":".1.3.6.1.4.1.2021.4.13.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":6,"name":"memBuffer","oid":".1.3.6.1.4.1.2021.4.14.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":7,"name":"memCached","oid":".1.3.6.1.4.1.2021.4.15.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":8,"name":"memTotalReal","oid":".1.3.6.1.4.1.2021.4.5.0","pollingType":"G","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":9,"name":"eth0 IN","oid":"1.3.6.1.2.1.2.2.1.10.2","pollingType":"C","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1},{"id":10,"name":"eth0 OUT","oid":"1.3.6.1.2.1.2.2.1.16.2","pollingType":"C","minValue":0,"maxValue":-1,"comment":"","thresholdComparator":"L","threshold":0,"thresholdFrequency":"M","profileId":0,"pollingPeriod":1}]}')
else
        echo "Monitoring profile already exists"
fi
at1=$(executeCurl $TOKEN 'PUT' "/profile/TyrellMonitoringPfl/attach?device=$ME1ID")
at2=$(executeCurl $TOKEN 'PUT' "/profile/TyrellMonitoringPfl/attach?device=$ME2ID")
echo "-----------------------------------------------------"
echo "CREATE AND CONFIGURE DASHBOARD"
echo "-----------------------------------------------------"
dashboardExist=$(executeCurl $TOKEN 'GET' "/orchestration/v1/summary/actor?customerId=$CUSTIDONLY")
if [[ $dashboardExist == *"kibana_dashboard"* ]]; then
        echo "Dashboard already exists"
else
        DASH_RAW=$(executeCurl $TOKEN 'POST' "/orchestration/service/execute/$CUSTID?serviceName=Process%2FAnalytics%2FKibana%2Fkibana_dashboard&processName=Process%2FAnalytics%2FKibana%2FProcess_Create_Report_Dashboard" '{"ipAddress":null,"basePath":"/kibana","index":".kibana","type":"dashboard","template_id":"template_default","dashboardName":"MiniLabDashboard","searchingURI":null,"uriPutES":null,"Hash":null,"kibanaUrl":null,"kibanaPort":"5601","kibanaIpAddress":null}')
        reg='.*SID([0-9]+)'
        [[ $DASH_RAW =~ $reg ]]
        DASH_SERVICEID=${BASH_REMATCH[1]}
        #echo "Sevice ID $DASH_SERVICEID"
        sleep 3
        HASH_RAW=$(executeCurl $TOKEN 'GET' "/orchestration/service/variables/$DASH_SERVICEID/Hash")
        reg='.*ash\s+:\s+(\w+)'
        [[ $HASH_RAW =~ $reg ]]
        HASH=${BASH_REMATCH[1]}
        #echo "KIB HAS $HASH"
        body='{"content":{"language":"en","drawerWidth":{"automationDetail":600},"tableRows":{"dashboard":12,"managedEntities":10,"automation":10,"configurations":10,"admin":10,"logs":10,"alarms":10,"monitoringProfiles":10,"permissionProfiles":10,"bpmOverview":10,"bpmDetails":10,"profileAuditLogs":10,"aiStates":10},"autoRefresh":60000,"dashboard":[{"style":"Dashboard Panel","type":"MSA Component","component":"Managed Entity Status","title":"Infrastructure","lg":6,"height":120},{"style":"Dashboard Panel","type":"MSA Component","component":"Automation","title":"Automation","lg":6,"height":120},{"style":"Dashboard Panel","type":"MSA Component","component":"Kibana Dashboard","title":"Dashboard","lg":12,"height":120,"extendedListValues":{"kibanaUrl":"<HASH>"}}]}}'
        body=${body/<HASH>/$HASH}
        #echo "BODY $body"
        #executeCurl $TOKEN 'PUT' "/repository/file?uri=Datafiles/.NCLG1_UI_SETTINGS.json" \'"$body"\'
        settings=$(executeCurl $TOKEN 'PUT' "/repository/file?uri=Datafiles/.NCLG1_UI_SETTINGS.json" '
        {
        	"content": {
        		"language": "en",
        		"drawerWidth": {
        			"automationDetail": 600
        		},
        		"tableRows": {
        			"dashboard": 12,
        			"managedEntities": 10,
        			"automation": 10,
        			"configurations": 10,
        			"admin": 10,
        			"logs": 10,
        			"alarms": 10,
        			"monitoringProfiles": 10,
        			"permissionProfiles": 10,
        			"bpmOverview": 10,
        			"bpmDetails": 10,
        			"profileAuditLogs": 10,
        			"aiStates": 10
        		},
                        "tableSortKey": { "automation": "lastupdated" },
                        "tableSortOrder": { "automation": 0 },
                        "autoRefresh": { // This is the right one
                                "managedEntityStatus": 60,
                                "ping": 5,
                                "notification": 60,
                                "pollingInterval": 2,
                                "topology": 30
                        },
        		"dashboard": [{
        			"style": "Dashboard Panel",
        			"type": "MSA Component",
        			"component": "Managed Entity Status",
        			"title": "Infrastructure",
        			"lg": 6,
        			"height": 120
        		}, {
        			"style": "Dashboard Panel",
        			"type": "MSA Component",
        			"component": "Automation",
        			"title": "Automation",
        			"lg": 6,
        			"height": 120
        		}, {
        			"style": "Dashboard Panel",
        			"type": "MSA Component",
        			"component": "Kibana Dashboard",
        			"title": "Dashboard",
        			"lg": 12,
        			"height": 120,
        			"extendedListValues": {
        				"kibanaUrl": "'"$HASH"'"
        			}
        		}]
        	}
        }        
        ')
fi
