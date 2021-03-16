#!/bin/bash

#TODO: find a better way to check all environment variables if they are set!

# check if used variables are set

if [ -z "${UCD_RELEASE_NAME}" ]; then 
   echo "UCD_RELEASE_NAME not set"
   exit 1
fi 

#
# TODO: need to create usefull ucdroute.yaml
#
echo "INFO: Installing Route"

oc create route passthrough ucd --service=${UCD_RELEASE_NAME}-ibm-ucd-prod --port=https

echo "SUCCESS: Installing Route"
