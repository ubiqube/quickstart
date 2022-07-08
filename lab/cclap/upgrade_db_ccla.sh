#!/bin/bash

PGHOST=''

if [ "$1" = 'preprod' ]; then
    PGHOST=p-dgv6rj0npe.remrgmjejz0pkkur.biganimal.io #PreProd
    DBPASS="$2"
fi

if [ "$1" = 'prod' ]; then
    PGHOST=p-x9xtf8920k.remrgmjejz0pkkur.biganimal.io #Prod
    DBPASS="$2"
fi

if [ -z "$PGHOST" ] | [ -z "$DBPASS" ]; then
    echo 'usage: upgrade_db_ccla.sh [ preprod PASS | prod PASS] '
    exit 1
fi

PG_USER=edb_admin
CAMUNDA_USER=camunda
KEY_VAULT_USER=key_vault
PG_PRIMARY_PORT=5432
PG_DATABASE=POSTGRESQL
CAMUNDA_DB=process-engine
KEY_VAULT_DB=key_vault

if [ ! -f "$HOME/.pgpass" ]; then
    rm -rf "$HOME/.pgpass"
fi

echo "${PGHOST}:${PG_PRIMARY_PORT}:${PG_DATABASE}:${PG_USER}:${DBPASS}" > "$HOME/.pgpass"
echo "${PGHOST}:${PG_PRIMARY_PORT}:${CAMUNDA_DB}:${CAMUNDA_USER}:camunda" >> "$HOME/.pgpass"
echo "${PGHOST}:${PG_PRIMARY_PORT}:${KEY_VAULT_DB}:${KEY_VAULT_USER}:ErNK_5WnilVsObP" >> "$HOME/.pgpass"
chmod 600 "$HOME/.pgpass"


pushd /db_schemas

declare -a ALTER_TABLES
ALTER_TABLES=(sms/scheme/SMS_triggers.sql sms/scheme/SMS_altertable.sql customer/scheme/CUST_PG_Triggers.sql 06_GRANT.sql)

echo '##############################'
echo 'Logs will be saved in the /tmp'
echo '##############################'

for i in "${ALTER_TABLES[@]}"; do
    echo '------------------------------'
    echo "Running ${i}..."
    echo -e "------------------------------\n\n"
    psql -U "${PG_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
        -d "${PG_DATABASE}" -f "$i" > /tmp/alter_tables.log
done
echo '##############################'
echo "General alter tables"
echo "##############################"

# Camunda DB creation if does not exist
CHECK_CAMUNDA=$(psql -U ${PG_USER} -h ${PGHOST} \
                     -p ${PG_PRIMARY_PORT} \
                     -d ${PG_DATABASE} -tAc \
                     "SELECT 1 FROM pg_database WHERE datname='${CAMUNDA_DB}'")

if [ "${CHECK_CAMUNDA}" != '1' ]; then
    echo '------------------------------'
    echo "Running Camunda..."
    echo -e "------------------------------\n\n"

    psql -U "${PG_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
        -d "${PG_DATABASE}" -f camunda/requests/CREATE_USER_AND_DB.sql

    psql -U "${CAMUNDA_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
        -d "${CAMUNDA_DB}" \
        -f camunda/create/postgres_engine_7.13.0.sql

    psql -U "${CAMUNDA_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
        -d "${CAMUNDA_DB}" \
        -f camunda/create/postgres_identity_7.13.0.sql
fi

# filesnames of sql patches in docker-entrypoint-initdb.d/camunda/upgrade/
# variable must be filled here
declare -a CAMUNDA_UPGRADES
CAMUNDA_UPGRADES=()
for cam_upgrade in "${CAMUNDA_UPGRADES[@]}"; do
    psql -U "${CAMUNDA_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
        -d "${CAMUNDA_DB}" \
        -f "camunda/upgrade/${cam_upgrade}"
done

echo '------------------------------'
echo "Running for Key vault..."
echo -e "------------------------------\n\n"
psql -U "${PG_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
    -d "${PG_DATABASE}" \
    -f key_vault/requests/CREATE_USER_AND_DB.sql

psql -U "${KEY_VAULT_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
    -d "${KEY_VAULT_DB}" -f key_vault/create/key_vault.sql

# # Mano DB creation if does not exist
# if [ "$(psql -h ${PGHOST} -tAc "SELECT 1 FROM pg_database WHERE datname='${KEYCLOAK_DB}'")" != '1' ]; then
#     echo_info "MANO DB does not exist. Creating..."
#     CREATE_MANO_USER="CREATE USER ${KEYCLOAK_USER} WITH CREATEDB PASSWORD '${KEYCLOAK_PASSWORD}';"
#     psql -U "${PG_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
#         -c "${CREATE_MANO_USER}"

#     CREATE_MANO_DB="CREATE DATABASE ${KEYCLOAK_DB} OWNER '${KEYCLOAK_USER}';"
#     psql -U "${PG_USER}" -h "${PGHOST}" -p "${PG_PRIMARY_PORT}" \
#         -c "${CREATE_MANO_DB}"
# fi

popd
