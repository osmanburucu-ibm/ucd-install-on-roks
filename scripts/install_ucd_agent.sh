#!/bin/bash

#TODO: find a better way to check all environment variables if they are set!

# check if used variables are set
if [ -z "${UCD_RELEASE_NAME}" ]; then 
   echo "UCD_RELEASE_NAME not set"
   exit 1
fi 

if [ -z "${UCDAGENT_RELEASE_NAME}" ]; then 
   echo "UCDAGENT_RELEASE_NAME not set"
   exit 1
fi 

if [ -z "${UCD_KEYSTORE_PASSWORD}" ]; then 
   echo "UCD_KEYSTORE_PASSWORD not set"
   exit 1
fi 


echo "INFO: Installing Agent"

oc create secret generic ${UCDAGENT_RELEASE_NAME}-secrets --from-literal=keystorepassword=${UCD_KEYSTORE_PASSWORD}

# change the template to actual UCD server releasename 
cp agent/my-ucdagentvalues.yaml my-ucdagentvalues.yaml
sed -i  "s/UCD-RELEASENAME/${UCD_RELEASE_NAME}/g" my-ucdagentvalues.yaml

helm template ${UCDAGENT_RELEASE_NAME} --values my-ucdagentvalues.yaml ibm-helm/ibm-ucda-prod -a security.openshift.io/v0 --set license.accept=true > ucdak8s.yaml
oc apply -f ucdak8s.yaml

UCDAgent_Pod_Name=`oc get pods | grep ${UCDAGENT_RELEASE_NAME} | cut -d " " -f 1`
UCDAgent_Pod_Status=`oc get pod | grep ${UCDAgent_Pod_Name} | awk '{print $3}'`
while [ $UCDAgent_Pod_Status != "Running" ]
do
   echo "INFO: Waiting for UCD Agent pod to get to Running state"
   sleep 10
   UCDAgent_Pod_Status=`oc get pod | grep ${UCDAgent_Pod_Name} | awk '{print $3}'`
done
echo "SUCCESS: Installing Agent - UCD Install complete"

#TODO: should be cleaning up an option?
rm ucdak8s.yaml
rm my-ucdagentvalues.yaml
