#!/bin/bash

# Параметры подключения к БД PostgreSQL
DB_HOST="host"
DB_PORT="port"
DB_NAME="dbname"
DB_USER="username"
DB_PASSWORD="password"


POST_URL="https://testserver.ru/api"


SCHEMA_LIST=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  -qt -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name != 'information_schema';")

for SCHEMA in $SCHEMA_LIST; do

  TABLE_QUERY="SELECT * FROM ${SCHEMA}.table_values WHERE KEY = 'KEY_PARAMETER' AND VALUE = 'true';"

  HAS_PARAMETER=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    -qt -c "$TABLE_QUERY" | wc -l)
  
  if [[ $HAS_PARAMETER -gt 0 ]]; then
    # Выполнение POST-запроса
    curl -X POST -H "Content-Type: application/json" -d "{\"schema_name\": \"$SCHEMA\"}" "$POST_URL"
  fi
done