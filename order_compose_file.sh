#!/bin/bash
set -e

order_compose_file()
{
  COMPOSE_FILE=$1

  # alphabetical ordering of a yaml file
  yq -i --string-interpolation=false -P 'sort_keys(..)' $COMPOSE_FILE
  # remove strange stuff added by ordering!
  sed -i 's/!!merge //g' $COMPOSE_FILE
  # put anchors if any to the begining of the file
  # anchors are supposed to be at the end of the initial file
  :> anchors
  :> body
  awk '/^x-/{found=1} !found {print > "body"} found {print > "anchors"}' $COMPOSE_FILE
  cat anchors body > $COMPOSE_FILE
}

for f in docker-compose.yml docker-compose.e2e.yml docker-compose.ha.yml docker-compose.ccla.yml docker-compose.ccla.ha.yml docker-compose.mariadb.yml
do
  order_compose_file $f
  if [[ ! $f =~ "ccla" ]]
  then
    docker compose -f $f config --dry-run > /dev/null || echo Invalid compose file $f due to above error 
  fi
done

rm -f anchors body
