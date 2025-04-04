#!/bin/bash


init()
{
KEYCLOAK_URL="https://keycloak.local.test"
KEYCLOAK_USER="admin"
KEYCLOAK_PASSWORD="s1cret0"
DOCKER_IMAGE="adorsys/keycloak-config-cli:latest"
}

init


docker run \
    --add-host=keycloak.local.test=172.17.0.1 \
    -e KEYCLOAK_URL="$KEYCLOAK_URL" \
    -e KEYCLOAK_USER="$KEYCLOAK_USER" \
    -e KEYCLOAK_PASSWORD="$KEYCLOAK_PASSWORD" \
    -e KEYCLOAK_SSLVERIFY=false \
    -e KEYCLOAK_AVAILABILITYCHECK_ENABLED=true \
    -e KEYCLOAK_AVAILABILITYCHECK_TIMEOUT=120s \
    -e IMPORT_VARSUBSTITUTION_ENABLED=true \
    -e IMPORT_FILES_LOCATIONS='/config/*' \
    --env-file ./.env \
    -v ./base/config:/config \
    $DOCKER_IMAGE