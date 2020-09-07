#!/bin/bash
#set -x

PROG=$(basename $0)

init_db() {
    USER="ncroot"
    PASSWORD="ubiqube"
    MSA_IP=msa_api

    RESPONSE=`curl -s -k -H 'Content-Type: application/json' -XPOST http://$MSA_IP:8480/ubi-api-rest/auth/token -d '{"username":"ncroot", "password":"ubiqube" }'`
    if [ -z "$RESPONSE" ]
    then
      echo "Authentication API error"
      exit 1
    fi
    TOKEN=$(php -r 'echo json_decode($argv[1])->token;' "$RESPONSE")
    #echo "Token: "$TOKEN

    curl -k -i -H 'Accept: application/json' -H 'Content-type: application/json' -H "Authorization: Bearer "$TOKEN -XPOST http://$MSA_IP:8480/ubi-api-rest/system-admin/v1/msa_vars -d \
        '[{
		"name": "UBI_ES_BULK_THREAD",
		"lastUpdate": "",
		"comment": "",
		"value": "2"
	},
	{
		"name": "UBI_ES_REFRESH_INTERVAL",
		"lastUpdate": "",
		"comment": "",
		"value": "1"
	},
	{
		"name": "UBI_ES_BULK_FILE_SIZE",
		"lastUpdate": "",
		"comment": "",
		"value": "10000000"
	},
	{
		"name": "UBI_ES_BULK_FILE_AGREGATION_TIME",
		"lastUpdate": "",
		"comment": "",
		"value": "10"
	},
	{
		"name": "UBI_SMS_POLLD_MIN_TO_DOWN",
		"lastUpdate": "",
		"comment": "",
		"value": "6"
	},
	{
		"name": "UBI_SMS_POLLD_OUTPUT_DELAY",
		"lastUpdate": "",
		"comment": "",
		"value": "3000"
	},
	{
		"name": "UBI_CUSTOMER_DB_USERSPACE",
		"lastUpdate": "",
		"comment": "",
		"value": "redone"
	},
	{
		"name": "UBI_CUSTOMER_DB_USERSPACE_PASSWORD",
		"lastUpdate": "",
		"comment": "",
		"value": "U2FsdGVkX1/5btSbCmKOrSjzlTg6Nj7bDY6XbTlcMSA="
	},
	{
		"name": "UBI_CUSTOMER_DB_NAME",
		"lastUpdate": "",
		"comment": "",
		"value": "POSTGRESQL"
	},
	{
		"name": "UBI_CUSTOMER_DB_USERNAME",
		"lastUpdate": "",
		"comment": "",
		"value": "ncgest"
	},
	{
		"name": "UBI_CUSTOMER_DB_PASSWORD",
		"lastUpdate": "",
		"comment": "",
		"value": "U2FsdGVkX19Ixisg9LOEI5yzzPqSvnDC6lTOIIaMhZBDgiQOKeOLIHNV5riceW+Z"
	},
	{
		"name": "UBI_SMS_DB_USERSPACE",
		"lastUpdate": "",
		"comment": "",
		"value": "redsms"
	},
	{
		"name": "UBI_SMS_DB_USERSPACE_PASSWORD",
		"lastUpdate": "",
		"comment": "",
		"value": "U2FsdGVkX1+oCAkIyfIgvle4Po3zDj28Va1YpkEyozQ="
	},
	{
		"name": "UBI_SMS_DB_NAME",
		"lastUpdate": "",
		"comment": "",
		"value": "POSTGRESQL"
	},
	{
		"name": "UBI_SMS_DB_USERNAME",
		"lastUpdate": "",
		"comment": "",
		"value": "ncgest"
	},
	{
		"name": "UBI_SMS_DB_PASSWORD",
		"lastUpdate": "",
		"comment": "",
		"value": "U2FsdGVkX19bU8qeTmb2vFyHbSmry+6PyvQf8TRjO8V6t/1ibf3vXVeRcTS4hgYJ"
	},
	{
		"name": "UBI_SES_NCROOT_PASSWORD",
		"lastUpdate": "",
		"comment": "",
		"value": "U2FsdGVkX1+5YdLqtJWg8e9qu3jPjBCFtopuhVflpSM="
	},
	{
		"name": "UBI_MAIL_SUPPORT_UBIQUBE",
		"lastUpdate": "",
		"comment": "",
		"value": "support@ubiqube.com"
	},
	{
		"name": "USE_SMTP",
		"lastUpdate": "",
		"comment": "",
		"value": "1"
	}, {
		"name": "UBI_MAIL_SUPPORT",
		"lastUpdate": "",
		"comment": "",
		"value": ""
	},
	{
		"name": "UBI_MAIL_FROM",
		"lastUpdate": "",
		"comment": "",
		"value": "msa@ubiqube.com"
	},
	{
		"name": "UBI_MAIL_COPY",
		"lastUpdate": "",
		"comment": "",
		"value": ""
	},
	{
		"name": "UBI_VSOC_ASSET_LEVEL",
		"lastUpdate": "",
		"comment": "",
		"value": "3"
	},
	{
		"name": "UBI_VSOC_DEBUG_LEVEL",
		"lastUpdate": "",
		"comment": "",
		"value": "0"
	},
	{
		"name": "UBI_SMS_INTERNAL_LOG_COMPRESS",
		"lastUpdate": "",
		"comment": "",
		"value": "1"
	},
	{
		"name": "UBI_SMS_INTERNAL_LOG_KEEP",
		"lastUpdate": "",
		"comment": "",
		"value": "30"
	},
	{
		"name": "UBI_SMS_SUPPORT_DYNAMIC_ADDRESSES",
		"lastUpdate": "",
		"comment": "",
		"value": "0"
	},
	{
		"name": "UBI_SMS_SYSLOG_AGREG_TIME",
		"lastUpdate": "",
		"comment": "",
		"value": "60"
	},
	{
		"name": "UBI_SMS_SYSLOG_MAX_BUFFER",
		"lastUpdate": "",
		"comment": "",
		"value": "50000"
	},
	{
		"name": "UBI_SMS_SYSLOG_DEFAULT_TIMEZONE_OFFSET",
		"lastUpdate": "",
		"comment": "",
		"value": "+0000"
	},
	{
		"name": "UBI_SMS_SUPPORT_BACKUP_SYSLOGS",
		"lastUpdate": "",
		"comment": "",
		"value": "0"
	},
	{
		"name": "UBI_SMS_BACKUP_SYSLOGS_PATH",
		"lastUpdate": "",
		"comment": "",
		"value": "/opt/sms/spool/syslog_backup"
	},
	{
		"name": "UBI_SMS_BACKUP_SYSLOGS_USAGE",
		"lastUpdate": "",
		"comment": "",
		"value": "20000"
	},
	{
		"name": "UBI_SMS_TINY_SYSLOGS",
		"lastUpdate": "",
		"comment": "",
		"value": "0"
	},
	{
		"name": "UBI_ALARM_SEV_CONF_CHANGED",
		"lastUpdate": "",
		"comment": "",
		"value": "1"
	},
	{
		"name": "UBI_ALARM_SEV_UPDATE_OK",
		"lastUpdate": "",
		"comment": "",
		"value": "6"
	},
	{
		"name": "UBI_ALARM_SEV_UPDATE_FAILED",
		"lastUpdate": "",
		"comment": "",
		"value": "1"
	},
	{
		"name": "UBI_SYSLOG_SSL",
		"lastUpdate": "",
		"comment": "",
		"value": "false"
	},
	{
		"name": "UBI_DISK_USAGE_CORE_DUMP",
		"lastUpdate": "",
		"comment": "",
		"value": "4096"
	},
	{
		"name": "UBI_DISK_DAYS_ROUTER_LOGS",
		"lastUpdate": "",
		"comment": "",
		"value": "30"
	},
	{
		"name": "UBI_DISK_DAYS_ROUTER_ALARMS",
		"lastUpdate": "",
		"comment": "",
		"value": "30"
	},
	{
		"name": "UBI_DISK_USAGE_INTERNAL_LOGS",
		"lastUpdate": "",
		"comment": "",
		"value": "4096"
	},
	{
		"name": "UBI_DISK_DAYS_SMARTY_CACHE",
		"lastUpdate": "",
		"comment": "",
		"value": "7"
	},
	{
		"name": "UBI_SMS_SAVE_ALL_CONF_START_TIME",
		"lastUpdate": "",
		"comment": "",
		"value": "01:30:00"
	},
	{
		"name": "UBI_SMS_SAVE_ALL_CONF_FREQUENCY",
		"lastUpdate": "",
		"comment": "",
		"value": "24:00:00"
	},
	{
		"name": "UBI_SMS_CHECK_ALERT_PERIOD",
		"lastUpdate": "",
		"comment": "",
		"value": "60"
	},
	{
		"name": "UBI_SMS_CHECK_ALERT_REAR_SHIFT",
		"lastUpdate": "",
		"comment": "",
		"value": "2"
	},
	{
		"name": "UBI_SMS_DB_KEEP_ALIVE",
		"lastUpdate": "",
		"comment": "",
		"value": "10"
	},
	{
		"name": "UBI_DISABLE_INTERNAL_EVENTS",
		"lastUpdate": "",
		"comment": "",
		"value": "false"
	},
	{
		"name": "UBI_ES_VERSION",
		"lastUpdate": "",
		"comment": "",
		"value": "7.2"
	},
	{
		"name": "UBI_ES_LOGINDEX_NAME",
		"lastUpdate": "",
		"comment": "",
		"value": "ubilogs"
	},
	{
		"name": "UBI_NEEDALL_LIST",
		"lastUpdate": "",
		"comment": "",
		"value": "localhost=127.0.0.1"
	},
	{
		"name": "UBI_NEEDONE_LIST",
		"lastUpdate": "",
		"comment": "",
		"value": "dns=127.0.0.11"
	},
	{
		"name": "UBI_SNMP_TRAP_LIST",
		"lastUpdate": "",
		"comment": "",
		"value": ""
	}
]'

echo
}

main() {
    init_db
}


main "$@"
