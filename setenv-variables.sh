#!/bin/bash
if [ $# -gt  0 ]; then
echo "There are 6 environment variables that you can set to control the installation (or you can just modify the install.sh to change the default values).  The only one that is mandatory is the ENTITLED_REGISTRY_KEY, the others are optional with sensible default values.  I would strongly recommend changing the two passwords.

ENTITLED_REGISTRY_KEY - the value of your entitled registry key, this is used to pull down the ucd docker images.
NAMESPACE - the namespace that ucd will be deployed to.  If it doesnt exist, it will get created.
MYSQL_PASSWORD - the password to the mysql database.  The mysql database is not exposed outside of the cluster.
UCD_ADMIN_PASSWORD - the password to ucd.  the UCD ui is on the public internet, so I woudl strongly recommend this is 32 characters plus.  The defaul value is admin !!!
UCD_RELEASE_NAME - this is the name of the helm release for ucd, and is also used as the basis of the route to the ucd server. TAKE CARE in some yaml files the name has also be changed!
UCDAGENT_RELEASE_NAME - this is the name of the helm release for the ucd agents.

Once you've set the environment variables you want to change, then you can just simply type

./install.sh

It should take about 5 minutes to install, and you will get progress information as it proceeds.";
exit 1;
fi

# if [ -z "${NAMESPACE}" ]; then NAMESPACE='ucd';  fi
# if [ -z "${MYSQL_PASSWORD}" ]; then MYSQL_PASSWORD='pleasechangeme123';  fi
# if [ -z "${UCD_ADMIN_PASSWORD}" ]; then UCD_ADMIN_PASSWORD='admin'; fi
# if [ -z "${UCD_RELEASE_NAME}" ]; then UCD_RELEASE_NAME='ucd710';  fi
# if [ -z "${UCDAGENT_RELEASE_NAME}" ]; then UCDAGENT_RELEASE_NAME='ucdagent710';  fi
# if [ -z "${UCD_KEYSTORE_PASSWORD}" ]; then UCD_KEYSTORE_PASSWORD='pleasechangeme123';  fi
# if [ -z "${STORAGE_CLASS}" ]; then STORAGE_CLASS='ibmc-vpc-block-10iops-tier';  fi

NAMESPACE=${NAMESPACE:-ucd2} 
MYSQL_PASSWORD=${MYSQL_PASSWORD:-pleasechangeme123}
UCD_RELEASE_NAME=${UCD_RELEASE_NAME:-ucd710}
UCDAGENT_RELEASE_NAME=${UCDAGENT_RELEASE_NAME:-ucdagent710}
UCD_KEYSTORE_PASSWORD=${UCD_KEYSTORE_PASSWORD:-pleasechangeme123}
STORAGE_CLASS=${STORAGE_CLASS:-ibmc-vpc-block-10iops-tierd}

if [ -z "${ENTITLED_REGISTRY_KEY}" ]; then 
  echo "You must set the environment variable ENTITLED_REGISTRY_KEY to the key of your entitled registry";
  exit 1;
fi
