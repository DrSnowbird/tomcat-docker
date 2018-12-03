#!/bin/bash

if [ -f "${CATALINA_HOME}/tomcat_admin_password" ]; then
    echo "Tomcat 'admin' user already created"
    exit 0
fi

env

#generate password


if [ "${TOMCAT_PASS}" == "" ]; then
    TOMCAT_PASS="$(pwgen -s 12 1)"
    echo "=> Creating an admin user with a ${TOMCAT_PASS} password in Tomcat"
fi

sed -i -r 's/<\/tomcat-users>//' ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="manager-jmx"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="admin-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '<role rolename="admin-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo "<user username=\"admin\" password=\"${TOMCAT_PASS}\" roles=\"manager-gui,manager-script,manager-jmx,admin-gui, admin-script\"/>" >> ${CATALINA_HOME}/conf/tomcat-users.xml
echo '</tomcat-users>' >> ${CATALINA_HOME}/conf/tomcat-users.xml 
echo "=> Done!"
echo "admin:${TOMCAT_PASS}" > ${CATALINA_HOME}/tomcat_admin_password

echo "========================================================================"
echo "You can now access to this Tomcat server using:"
echo ""
echo "    admin:${TOMCAT_PASS}"
echo ""
echo "========================================================================"
