#!/bin/bash -x

env

if [ ! -f ${CATALINA_HOME}/tomcat_admin_password ]; then
    ${CATALINA_HOME}/create_tomcat_admin_user.sh ${TOMCAT_PASS}
    ${CATALINA_HOME}/setup-https-tomcat.sh
fi

exec ${CATALINA_HOME}/bin/catalina.sh run
