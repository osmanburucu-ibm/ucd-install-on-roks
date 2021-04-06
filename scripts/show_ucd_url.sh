#!/bin/bash

# check if used variables are set
if [ -z "${UCD_ADMIN_PASSWORD}" ]; then 
   echo "UCD_ADMIN_PASSWORD not set"
   exit 1
fi 

#TODO: as route name ucd is first used in create_route need to have more flexible way if it needs to be changed!
Server_Address=`oc get route ucd -o=jsonpath="{@.spec.host}"`

echo "The UCD server can be found at https://${Server_Address} and the credentials are admin/${UCD_ADMIN_PASSWORD}"

# NOTES:
# 1. Get the application URL by running these commands if NODEPORT is used
# ~~~sh
#   export NODE_PORT=$(kubectl get --namespace ${NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}" services  ${UCD_RELEASE_NAME}-ibm-ucd-prod)
#   export NODE_IP=$(kubectl get nodes --namespace ${NAMESPACE} -o jsonpath="{.items[0].status.addresses[0].address}")
#   echo https://$NODE_IP:$NODE_PORT
# ~~~