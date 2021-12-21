#!/bin/bash
set -x

ID=$1
PROG=$(basename $0)

rm -rf docker-compose-$ID.yml 
cp -f docker-compose.yml docker-compose-$ID.yml 

sed -i  "s/container_name: msa_front/container_name: msa_front_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_db/container_name: msa_db_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_api/container_name: msa_api_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_ui/container_name: msa_ui_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_monitoring/container_name: msa_monitoring_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_sms/container_name: msa_sms_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_bud/container_name: msa_bud_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_alarm/container_name: msa_alarm_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_camunda/container_name: msa_camunda_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_es/container_name: msa_es_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_cerebro/container_name: msa_cerebro_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_dev/container_name: msa_dev_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_kibana/container_name: msa_kibana_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: msa_ai_ml/container_name: msa_ai_ml_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: linux_me/container_name: linux_me_$ID/" docker-compose-$ID.yml
sed -i  "s/container_name: linux_me_2/container_name: linux_me_2_$ID/" docker-compose-$ID.yml
sed -i  "s/db:5432/msa_db_$ID:5432/" docker-compose-$ID.yml
sed -i  "s/msa_es:9200/msa_es_$ID:9200/" docker-compose-$ID.yml
sed -i  "s/9000:9000/"$ID"9000:9000/" docker-compose-$ID.yml
sed -i  "s/5601:5601/"$ID"5601:5601/" docker-compose-$ID.yml
sed -i  "s/8000:8000/"$ID"8000:8000/" docker-compose-$ID.yml
sed -i  "s/2224:22/"$ID"2224:22/" docker-compose-$ID.yml
sed -i  "s/2225:22/"$ID"2225:22/" docker-compose-$ID.yml

sed -i  "s/published: 80/published: 1"$ID"080/" docker-compose-$ID.yml
sed -i  "s/published: 443/published: 1"$ID"443/" docker-compose-$ID.yml
sed -i  "s/published: 514/published: 1"$ID"514/" docker-compose-$ID.yml
sed -i  "s/published: 162/published: 1"$ID"162/" docker-compose-$ID.yml
sed -i  "s/published: 69/published: "1$ID"069/" docker-compose-$ID.yml
sed -i  "s/5200-5200/"$ID"5200-"$ID"5200/" docker-compose-$ID.yml

sed -i  "s/172.20.0.102/172.20."$ID".102/" docker-compose-$ID.yml
sed -i  "s/172.20.0.101/172.20."$ID".101/" docker-compose-$ID.yml
sed -i  "s/subnet: 172.20.0.0/subnet: 172.20."$ID".0/" docker-compose-$ID.yml
sed -i  "s/name: quickstart_default/name: quickstart_default_$ID/" docker-compose-$ID.yml

sed -i "s/docker-compose up -d/docker-compose -f docker-compose-"$ID"\.yml up -d/" ./scripts/install.sh
sed -i "s/5601\/kibana/"$ID"5601\/kibana/" ./scripts/install.sh
