#!/bin/bash

# check if used variables are set
if [ -z "${UCD_ADMIN_PASSWORD}" ]; then 
   echo "UCD_ADMIN_PASSWORD not set"
   exit 1
fi 

#TODO: as route name ucd is first used in create_route need to have more flexible way if it needs to be changed!
Server_Address=`oc get route ucd -o=jsonpath="{@.spec.host}"`

echo "The UCD server can be found at https://${Server_Address} and the credentials are admin/${UCD_ADMIN_PASSWORD}"