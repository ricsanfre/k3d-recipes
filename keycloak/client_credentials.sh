#!/bin/bash


# Script requires installation of pup command
# Binary available in https://github.com/ericchiang/pup

init()
{
KEYCLOAK_URL="https://keycloak.mycluster.local"
REDIRECT_URL="http://localhost:8080"
USERNAME="user1"
SCOPES="openid testapp-scope"
REALM="test"
CLIENTID="testclient"
CLIENTSECRET="ecWhOtnDp3exGqlssrNLLbtXsHLC5Bue"
}

decode() {
  jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $1
}

init

COOKIE="`pwd`/cookie.jar"

ACCESS_TOKEN=$(curl -ksS --cookie "$COOKIE" --cookie-jar "$COOKIE" \
  --data-urlencode "client_id=$CLIENTID" \
  --data-urlencode "client_secret=$CLIENTSECRET" \
  --data-urlencode "grant_type=client_credentials" \
  "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
  | jq -r ".access_token")

echo "access token : $ACCESS_TOKEN" 
echo " "

echo "Decoded Access Token: "
decode $ACCESS_TOKEN

rm $COOKIE