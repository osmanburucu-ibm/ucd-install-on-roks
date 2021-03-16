#!/bin/bash

#TODO: find a better way to check all environment variables if they are set!

# check if used variables are set
if [ -z "${ENTITLED_REGISTRY_KEY}" ]; then 
   echo "ENTITLED_REGISTRY_KEY not set"
   exit 1
fi 

if [ -z "${UCD_ADMIN_PASSWORD}" ]; then 
   echo "UCD_ADMIN_PASSWORD not set"
   exit 1
fi 

if [ -z "${MYSQL_PASSWORD}" ]; then 
   echo "MYSQL_PASSWORD not set"
   exit 1
fi 

if [ -z "${UCD_KEYSTORE_PASSWORD}" ]; then 
   echo "UCD_KEYSTORE_PASSWORD not set"
   exit 1
fi 

#
# create secret for IBM Container Registry (cp.icr.io) entitlement and add new secret to serviceaccount
#
echo "INFO: Configuring secrets and config maps"

oc create secret docker-registry entitledregistry-secret --docker-username=cp --docker-password=${ENTITLED_REGISTRY_KEY} --docker-server=cp.icr.io
oc patch serviceaccount/default --type='json' -p='[{"op":"add","path":"/imagePullSecrets/-","value":{"name":"entitledregistry-secret"}}]'

#
# encode ucd admin and mysql db password and generate secrets out of them (ucDBSecret.yaml)
#
UCD_PWD_BASE64=`echo ${UCD_ADMIN_PASSWORD} | base64`
MYSQL_PWD_BASE64=`echo password | base64`
oc create secret generic ucd-secrets --from-literal=dbpassword=${MYSQL_PASSWORD} --from-literal=initpassword=${UCD_ADMIN_PASSWORD} --from-literal=keystorepassword=${UCD_KEYSTORE_PASSWORD}

#
# add script for automatic driver download for ucd server
#
oc create -f db/mysqldriverConfigMap.yaml

echo "SUCCESS: Configured secrets and config maps"
