#!/bin/bash

echo '🏗️ Wait until all containers are healthy'

declare -a CONTAINER_LIST=(msa-alarm msa-api msa-auth msa-broker msa-bud msa-camunda msa-cerebro msa-db msa-dev msa-es msa-front msa-kibana msa-mongodb msa-monitor-writer msa-monitoring msa-parse msa-rsyslog msa-sms msa-smtp msa-snmptrap msa-ui)
declare -A RESULT_STATUS=()
declare -A RESULT_HEALTH=()

COUNTER=0
MAX=20

while [[ $COUNTER -lt $MAX ]]; do
    for c in "${CONTAINER_LIST[@]}"; do
        CONTAINER="dev-msa_${c}_1"
        if [ -z "${RESULT[$CONTAINER]}" ]; then
          STATUS=$(docker inspect "$CONTAINER" --format '{{.State.Status}}')
          HEALTH=$(docker inspect "$CONTAINER" --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}')
          RESULT_STATUS[$CONTAINER]=$STATUS
          RESULT_HEALTH[$CONTAINER]=$HEALTH
          if [[ $HEALTH == 'healthy' ]]; then
              CONTAINER_LIST=(${CONTAINER_LIST[@]/$c})
          fi
        fi
    done
    for key in "${!RESULT_HEALTH[@]}"; do
      printf "\e[1m%-40s\e[0m" "$key"
      if [[ "${RESULT_STATUS[$key]}" == "running" ]]; then
        printf "\e[0;32m%-20s\e[0m" "${RESULT_STATUS[$key]}"
      else
        printf "\e[0;37m%-20s\e[0m" "${RESULT_STATUS[$key]}"
      fi
      if [[ "${RESULT_HEALTH[$key]}" == "healthy" ]]; then
        printf "\e[0;32m%s\e[0m\n" "${RESULT_HEALTH[$key]}"
      else
        printf "\e[0;37m%s\e[0m\n" "${RESULT_HEALTH[$key]}"
      fi
    done
    echo
    if (( ${#CONTAINER_LIST[@]} == 0 )); then
        echo -e "✅ \e[1;37mOK.\e[0m"
        exit 0
    fi
    (( COUNTER++ ))
    sleep 5
done
if (( ${#CONTAINER_LIST[@]} == 0)); then
     echo -e "✅ \e[1;37mOK.\e[0m"
     exit 0
fi
echo -e "🎃 \e[1;31mFailed.\e[0m"
exit 1