#!/bin/bash

echo "There are 6 environment variables that you can set to control the installation (or you can just modify the install.sh to change the default values).  The only one that is mandatory is the ENTITLED_REGISTRY_KEY, the others are optional with sensible default values.  I would strongly recommend changing the two passwords.

ENTITLED_REGISTRY_KEY - the value of your entitled registry key, this is used to pull down the ucd docker images.
NAMESPACE - the namespace that ucd will be deployed to.  If it doesnt exist, it will get created.
MYSQL_PASSWORD - the password to the mysql database.  The mysql database is not exposed outside of the cluster.
UCD_ADMIN_PASSWORD - the password to ucd.  the UCD ui is on the public internet, so I woudl strongly recommend this is 32 characters plus.  The defaul value is admin !!!
UCD_RELEASE_NAME - this is the name of the helm release for ucd, and is also used as the basis of the route to the ucd server. TAKE CARE in some yaml files the name has also be changed!
UCDAGENT_RELEASE_NAME - this is the name of the helm release for the ucd agents.

Once you've set the environment variables you want to change, then you can just simply type

./install.sh (if you have all the storages pre-allocated)

or 

./install-vpc.sh (if you want an all-in script)

It should take about 5 minutes to install, and you will get progress information as it proceeds.";
