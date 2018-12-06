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

#### ---- Use Copy file instead (see Dockerfile COPY <...>/context.xml -----
runThis=0
if [ $runThis -gt 1 ]; then
    #### ---- For a manager to be accessible from any host/IP, you need to do the following.
    sed -i '/<Context/a \<!--' ${CATALINA_HOME}/webapps/manager/META-INF/context.xml
    sed -i '/<\/Context/i --\>' ${CATALINA_HOME}/webapps/manager/META-INF/context.xml  
    MANAGER_FILTER="<Manager sessionAttributeValueClassNameFilter=\"java\\\\.lang\\\\.(?:Boolean|Integer|Long|Number|String)|org\\\\.apache\\\\.catalina\\\\.filters\\\\.CsrfPreventionFilter\\\\\$LruCache(?:\\\\\$1)?|java\\\\.util\\\\.(?:Linked)?HashMap\"/>"
    sed -i '/<\/Context/i '"${MANAGER_FILTER}" ${CATALINA_HOME}/webapps/manager/META-INF/context.xml
fi
