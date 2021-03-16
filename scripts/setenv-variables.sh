#!/bin/bash

# if [ -z "${NAMESPACE}" ]; then NAMESPACE='ucd';  fi
# if [ -z "${MYSQL_PASSWORD}" ]; then MYSQL_PASSWORD='pleasechangeme123';  fi
# if [ -z "${UCD_ADMIN_PASSWORD}" ]; then UCD_ADMIN_PASSWORD='admin'; fi
# if [ -z "${UCD_RELEASE_NAME}" ]; then UCD_RELEASE_NAME='ucd710';  fi
# if [ -z "${UCDAGENT_RELEASE_NAME}" ]; then UCDAGENT_RELEASE_NAME='ucdagent710';  fi
# if [ -z "${UCD_KEYSTORE_PASSWORD}" ]; then UCD_KEYSTORE_PASSWORD='pleasechangeme123';  fi
# if [ -z "${STORAGE_CLASS}" ]; then STORAGE_CLASS='ibmc-vpc-block-10iops-tier';  fi

export NAMESPACE=${NAMESPACE:-ucd2} 
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-pleasechangeme123}
export UCD_RELEASE_NAME=${UCD_RELEASE_NAME:-ucd710}
export UCDAGENT_RELEASE_NAME=${UCDAGENT_RELEASE_NAME:-ucdagent710}
export UCD_KEYSTORE_PASSWORD=${UCD_KEYSTORE_PASSWORD:-pleasechangeme123}
export STORAGE_CLASS=${STORAGE_CLASS:-ibmc-block-gold}

if [ -z "${ENTITLED_REGISTRY_KEY}" ]; then 
  echo "You must set the environment variable ENTITLED_REGISTRY_KEY to the key of your entitled registry";
  exit 1;
fi
