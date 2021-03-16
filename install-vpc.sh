#!/bin/bash
# TODO: react to return values of scripts (1 is fail, 0 is ok)
if [ "$#" -gt  0 ]; then
  scripts/showHelp.sh
  exit 1
fi

source scripts/setenv-variables.sh

echo "Starting the installation of UrbanCode Deploy Server and Agent"

# create Project/Namespace
scripts/createProject.sh

# Create the my sql database
scripts/create_configure_DB.sh

# create secret for IBM Container Registry (cp.icr.io) entitlement and add new secret to serviceaccount
scripts/configure_secrets_configmaps.sh

# Installing UCD Server
scripts/install_ucd_server.sh

# Create Route to UCD Server
scripts/create_route.sh

# Installing the Agent
scripts/install_ucd_agent.sh

# show UCD URL
scripts/show_ucd_url.sh
