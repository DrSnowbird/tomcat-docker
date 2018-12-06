#!/bin/bash

if [ -f "${CATALINA_HOME}/tomcat_admin_password" ]; then
    echo "Tomcat 'admin' user already created"
    exit 0
fi

env

if [ "${TOMCAT_PASSWORD}" == "" ]; then
    TOMCAT_PASSWORD="$(pwgen -s 12 1)"
    echo "-------------------------------------------------------------------"
    echo "=> Creating some 'random' admin password for Tomcat: ${TOMCAT_PASSWORD}"
    echo "-------------------------------------------------------------------"
fi
echo "-----------------------------------------------------------------------"
echo "--------- Setup admin and manager-gui, etc roles for users ------------"
echo "-----------------------------------------------------------------------"
sed -i -r 's/<\/tomcat-users>//' ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-jmx"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-status"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="admin-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="admin-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo "<user username=\"tomcat\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>" >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo "<user username=\"admin\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>" >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '</tomcat-users>' >> ${CATALINA_HOME}/conf/tomcat-users.xml 
echo "=> Done!"
echo "admin:${TOMCAT_PASSWORD}" > ${CATALINA_HOME}/tomcat_admin_password
echo "========================================================================"
echo "You can now access to this Tomcat server using login/password as below:"
echo ""
echo "    admin : ${TOMCAT_PASSWORD}"
echo ""
echo "========================================================================"

#### ---- Commented out for now ----
runThis=1
if [ $runThis -gt 1 ]; then
    echo "----------------------------------------------------------------"
    echo "---- Setup Tomcat 8 to allow access Application Manager GUI ----"
    echo "----------------------------------------------------------------"
    #### Reference: https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/
    TOMCAT_PORT_HTTPS=${TOMCAT_PORT_HTTPS:-8443}
    ## temparily hard-coded IP - TODO: change it to whatever
    #HOST_IP_ADDRESS=${HOST_IP_ADDRESS:-"0.0.0.0"}
    HOST_IP_ADDRESS="192.168.0.160"
    HTTPS_CONNECTOR="redirectPort=\"${TOMCAT_PORT_HTTPS}\" address=\"${HOST_IP_ADDRESS}\" useIPVHosts=\"true\" />"
    sed -i 's#redirectPort="8443"\s*/>#'"${HTTPS_CONNECTOR}"'#' ${CATALINA_HOME}/conf/server.xml 
    #HOST_IP_ADDRESS=${HOST_IP_ADDRESS:-"0\.0\.0\.0"}
#    HOST_IP_ADDRESS="192\.168\.0\.160"
    sed -i 's#allow=\"127#allow=\"192.168.0.160|127#' ${CATALINA_HOME}/webapps/manager/META-INF/context.xml 
#    sed -i 's#allow=\"127\\#allow=\"'"${HOST_IP_ADDRESS}"'|127\\#' ${CATALINA_HOME}/webapps/manager/META-INF/context.xml 
fi
