#!/bin/bash

# check if used variables are set
if [ -z "${STORAGE_CLASS}" ]; then 
   echo "STORAGE_CLASS not set"
   exit 1
fi 

if [ -z "${MYSQL_PASSWORD}" ]; then 
   echo "MYSQL_PASSWORD not set"
   exit 1
fi 

#
# Create the my sql database
# use template version from db directory and replace storage class 
#
echo "INFO: creating the mysql database"

cp db/mysql-pvc.yaml mysql-pvc.yaml
sed -i  "s/storage_class:.*/storage_class: ${STORAGE_CLASS}/" mysql-pvc.yaml

oc apply -f ./mysql-pvc.yaml

PVCStatus=`oc get pvc mysql-pvc -o=jsonpath="{@.status.phase}"`
while [ $PVCStatus != "Bound" ]
do
  echo "INFO: Waiting for PVC to bind"
  sleep 10
  PVCStatus=`oc get pvc mysql-pvc -o=jsonpath="{@.status.phase}"`
done
echo "INFO: PVC is bound."

oc apply -f db/mysql.yaml
oc apply -f db/mysqlservice.yaml

MySQL_Pod_Name=`oc get pods | grep mysql | cut -d " " -f 1`
MySQL_Pod_Status=`oc get pod | grep ${MySQL_Pod_Name} | awk '{print $3}'`
while [ $MySQL_Pod_Status != "Running" ]
do
   echo "INFO: Waiting for MYSQL pod to get to Running state"
   sleep 10
   MySQL_Pod_Status=`oc get pod | grep ${MySQL_Pod_Name} | awk '{print $3}'`
done
sleep 20

echo "SUCCESS: MYSQL is running"

#
# configure database. create table, user and add grant
#
echo "INFO: Configuring mysql database"

oc exec -it $MySQL_Pod_Name -- mysql -u root -ppassword -e "CREATE USER 'ibm_ucd'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
oc exec -it $MySQL_Pod_Name -- mysql -u root -ppassword -e "CREATE DATABASE ibm_ucd character set utf8 collate utf8_bin;"
oc exec -it $MySQL_Pod_Name -- mysql -u root -ppassword -e "GRANT ALL ON ibm_ucd.* TO 'ibm_ucd'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;"

echo "SUCCESS: MYSQL is configured with the ucd database"

# TODO: should be cleaning up optional?
rm mysql-pvc.yaml
