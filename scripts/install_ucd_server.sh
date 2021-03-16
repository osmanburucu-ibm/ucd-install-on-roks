#!/bin/bash

#TODO: find a better way to check all environment variables if they are set!

# check if used variables are set

if [ -z "${UCD_RELEASE_NAME}" ]; then 
   echo "UCD_RELEASE_NAME not set"
   exit 1
fi 

if [ -z "${STORAGE_CLASS}" ]; then 
   echo "STORAGE_CLASS not set"
   exit 1
fi 

#
# Installing UCD Server
#
echo "INFO: Installing UCD Server"
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
#  if update of myvalues is needed generate a new one and edit the appropiate fields there.
#  helm inspect values ibm-helm/ibm-ucd-prod > myvalues.yaml

# prepare storage for application data and external library (f.e. mysql driver)
cp server/ucd-pvc.yaml ucd-pvc.yaml
sed -i  "s/storage_class:.*/storage_class: ${STORAGE_CLASS}/g" ucd-pvc.yaml
oc apply -f ./ucd-pvc.yaml

PVCStatus=`oc get pvc appdata-pvc -o=jsonpath="{@.status.phase}"`
while [ $PVCStatus != "Bound" ]
do
  echo "INFO: Waiting for PVC to bind"
  sleep 10
  PVCStatus=`oc get pvc appdata-pvc -o=jsonpath="{@.status.phase}"`
done
echo "INFO: PVC is bound."

# the actual installation process
# combine my settings from myvalues with openshift security settings and accept license

cp server/myvalues.yaml myvalues.yaml
helm template ${UCD_RELEASE_NAME} ibm-helm/ibm-ucd-prod -a security.openshift.io/v0 --values myvalues.yaml --set license.accept=true > ucdk8s.yaml
oc apply -f ./ucdk8s.yaml

UCD_Pod_Name=`oc get pods | grep ${UCD_RELEASE_NAME} | cut -d " " -f 1`
UCD_Pod_Status=`oc get pod | grep ${UCD_Pod_Name} | awk '{print $3}'`
while [ $UCD_Pod_Status != "Running" ]
do
   echo "INFO: Waiting for UCD pod to get to Running state"
   sleep 10
   UCD_Pod_Status=`oc get pod | grep ${UCD_Pod_Name} | awk '{print $3}'`
done

echo "SUCCESS: Installed UCD Server"

#TODO: should be cleaning up an option?
rm ucdk8s.yaml
rm ucd-pvc.yaml
rm myvalues.yaml
