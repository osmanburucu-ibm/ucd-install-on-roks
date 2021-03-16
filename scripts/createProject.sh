#!/bin/bash

# check if used variables are set
if [ -z "${NAMESPACE}" ]; then 
   echo "NAMESPACE not set"
   exit 1
fi 

#
# Create the project
#
echo "INFO: creating the project"

# check if namespace/project exists
array=(`oc get project ${NAMESPACE}`)
if [ "${#array[*]}" -gt  0 ]; then
   echo "ERROR:  Namespace/Project ${NAMESPACE} already exists.  Please delete the namespace/project or try a different name.";
   exit 1
else
   oc new-project ${NAMESPACE};
   oc adm policy add-scc-to-group ibm-restricted-scc system:serviceaccounts:${NAMESPACE};
fi 

echo "SUCCESS: creating the project"
