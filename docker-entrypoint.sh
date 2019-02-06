#!/bin/bash

set -e
env
#### ---- Make sure to provide Non-root user for launching Docker ----
#### ---- Default, we use base images's "developer"               ----
NON_ROOT_USER=${1:-"${USER_NAME}"}
NON_ROOT_USER=${NON_ROOT_USER:-"developer"}

#### ------------------------------------------------------------------------
#### ---- You need to set PRODUCT_EXE as the full-path executable binary ----
#### ------------------------------------------------------------------------
echo "Starting docker process daemon ..."
/bin/bash -c "${EXE_COMMAND:-echo Hello}"

${CATALINA_HOME}/bin/catalina.sh start
sleep 5
${CATALINA_HOME}/bin/catalina.sh stop

echo "=============================================================="
echo "=========== Setup Tomcat Admin/User configuration: ==========="
echo "==============================================================="
${CATALINA_HOME}/create_tomcat_admin_user.sh ${TOMCAT_PASSWORD}

echo "=================================================="
echo "=========== Setup HTTPS configuration: ==========="
echo "=================================================="
# - To enable HTTPS or not: 1=true / 0=false -
# TOMCAT_HTTPS_ENABLED=1
if [ ${TOMCAT_HTTPS_ENABLED} -gt 0 ]; then
    echo ">>>> Tomcat: Enable HTTPS per configuration from environment variable TOMCAT_HTTPS_ENABLED=$TOMCAT_HTTPS_ENABLED"
    ${CATALINA_HOME}/setup-https-tomcat.sh ${HOME}
else
    echo ">>>> Tomcat: Disabled HTTPS per configuration from environment variable TOMCAT_HTTPS_ENABLED=$TOMCAT_HTTPS_ENABLED"
fi

#### ------------------------------------------------------------------------
#### ---- Extra line added in the script to run all command line arguments
#### ---- To keep the docker process staying alive if needed.
#### ------------------------------------------------------------------------

#### **** Change this to your command pattern **** ####
EXE_PATTERN="catalina.sh"

#### **** Start processing command **** ####

#### 0.) Setup needed stuffs, e.g., init db etc. ....
#### (do something here for preparation if any)
    

#### 1.) Use cap_net_bind_service to allow Non-root user to access lower 1000 ports
#exec ${CATALINA_HOME}/bin/catalina.sh run "$@"
#exec authbind --deep ${CATALINA_HOME}/catalina.sh start "$@"
exec ${CATALINA_HOME}/bin/catalina.sh run "$@"

#### 2.) As Non-Root User -- Choose this or 2.A  ---- #### 
#### ---- Use this when running Non-Root user ---- ####
#### ---- Use gosu (or su-exec) to drop to a non-root user
#exec gosu ${NON_ROOT_USER} ${CATALINA_HOME}/bin/catalina.sh run "$@"



