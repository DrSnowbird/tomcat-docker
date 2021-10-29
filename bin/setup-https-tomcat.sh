#!/bin/bash -x

set -e

#### ------------------------
#### ---- HTTPS setup:   ----
#### ------------------------

export KEYSTORE_DIR=${1:-"${HOME}"}
#export KEYSTORE_DIR=./test-keystore

#KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-"ChangeMe!"}

if [ "${KEYSTORE_PASSWORD}" == "" ]; then
    ## -- setup random password --
    KEYSTORE_PASSWORD="$(pwgen -s 12 1)"
fi

echo "========================================================================"
echo "=> ***** KeyStore PASSWORD for configuring HTTPS Tomcat"
echo "${KEYSTORE_PASSWORD}" > ${KEYSTORE_DIR}/.tomcat_keystore_password
echo ""
echo ">>>>> The KeyStore and passwords for Tomcat server:"
echo " "
echo "    KeyStore File: ${KEYSTORE_DIR}/.keystore"
echo "    KeyStore Password: ${KEYSTORE_PASSWORD}"
echo "    KeyStore Password file: ${KEYSTORE_DIR}/.tomcat_keystore_password"
echo "    Tomcat HTTPS PORT: ${TOMCAT_PORT_HTTPS}"
echo "    WebProtege HTTPS PORT: ${WEBPROTEGE_PORT_HTTPS} (Should be the same as TOMCAT_PORT_HTTPS)"
echo " "
echo "========================================================================"
export KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}

if [ ! -d ${CATALINA_HOME}/conf ]; then
    echo "***************************************************************"
    echo "******* ERROR: Missing ${CATALINA_HOME}/conf directory *********"
    echo "***************************************************************"
    exit 1
fi
if [ ! -s "${KEYSTORE_DIR}/.keystore" ]; then
    #### ---- Generate .keystore ----
    #$JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA -keystore ${KEYSTORE_DIR}/.keystore
    $JAVA_HOME/bin/keytool -genkey -noprompt \
        -alias tomcat \
        -keyalg RSA \
        -dname "CN=openkbs.org, OU=OU, O=OpenKBS, L=City, ST=State, C=US" \
        -keystore "${KEYSTORE_DIR}/.keystore" \
        -storepass "${KEYSTORE_PASSWORD}" \
        -keypass "${KEYSTORE_PASSWORD}"
    #### ---- Convert to pkcs12 ----
    echo "${KEYSTORE_PASSWORD}" | $JAVA_HOME/bin/keytool -noprompt -importkeystore -srckeystore ${KEYSTORE_DIR}/.keystore -destkeystore ${KEYSTORE_DIR}/.keystore -deststoretype pkcs12

    # Warning:
    #The JKS keystore uses a proprietary format. It is recommended to migrate to PKCS12 which is an industry standard format using 
    #"keytool -importkeystore -srckeystore ./test-keystore/keystore -destkeystore ./test-keystore/keystore -deststoretype pkcs12".
    #keytool -noprompt -importkeystore -srckeystore ./test-keystore/keystore -destkeystore ./test-keystore/keystore -deststoretype pkcs12 -storepass '_KeyStore_Pass_ChangeMe!_' -keypass '_KeyStore_Pass_ChangeMe!_' 
fi

###########################################################################################################
#### ---- Setup HTTPS Port in ${CATALINA_HOME}/webapp/ROOT/WEB-INF/classes/webprotege.properties" ---- ####
###########################################################################################################
#### ---------------------------------------------
#### ---- Replace "Key=Value" withe new value ----
#### ---------------------------------------------
function replaceKeyValue() {
    inFile=${1}
    keyLike=$2
    newValue=$3
    if [ "$2" == "" ]; then
        echo "**** ERROR: Empty Key value! Abort!"
        exit 1
    fi
    sed -i -E 's/^('$keyLike'[[:blank:]]*=[[:blank:]]*).*/\1'$newValue'/' $inFile
}

###################################################################################
#### ---- Insert HTTPS Connector into $CATALINA_HOME/conf/server.xml file ---- ####
###################################################################################
echo ""
echo "*****************************************************************"
echo "******* Config Tomcat: ${CATALINA_HOME}/conf/server.xml *********"
echo "*****************************************************************"
echo ""
#HTTPS_CONNECTOR="<!-- Define a SSL Coyote HTTP/1.1 Connector on port 8443 --> \n<Connector \n protocol=\"org.apache.coyote.http11.Http11NioProtocol\"  \n port=\"8443\" maxThreads=\"200\"  \n scheme=\"https\" secure=\"true\" SSLEnabled=\"true\"  \n keystoreFile=\"\${user.home}/.keystore\" keystorePass=\"${KEYSTORE_PASSWORD}\"  \n clientAuth=\"false\" sslProtocol=\"TLS\"/>"
HTTPS_CONNECTOR="<!-- Define a SSL Coyote HTTP/1.1 Connector on port ${TOMCAT_PORT_HTTPS} --> \n<Connector \n protocol=\"org.apache.coyote.http11.Http11NioProtocol\"  \n port=\"${TOMCAT_PORT_HTTPS}\" maxThreads=\"200\"  \n scheme=\"https\" secure=\"true\" SSLEnabled=\"true\"  \n keystoreFile=\"\${user.home}/.keystore\" keystorePass=\"${KEYSTORE_PASSWORD}\"  \n clientAuth=\"false\" sslProtocol=\"TLS\"/>"

# Be careful to substitute the /path/to/my/keystore with the correct path to your keystore, which you generated in step one. Note that this connector is already present in the tomcat server.xml file, but it is commented-out. It is very important to set the connector to listen to port 443, because webprotege will always use the default https port, which is 443, and the default Tomcat connector will only listen on port 8443.

## -- Save the original once forever as template --
if [ ! -s ${CATALINA_HOME}/conf/server.xml.ORIGINAL ]; then
    cp ${CATALINA_HOME}/conf/server.xml ${CATALINA_HOME}/conf/server.xml.ORIGINAL
fi

## -- Copy from Original as new target file --
mkdir -p ${CATALINA_HOME}/conf/SAVED
cp --backup=numbered ${CATALINA_HOME}/conf/server.xml ${CATALINA_HOME}/conf/SAVED
cp ${CATALINA_HOME}/conf/server.xml.ORIGINAL ${CATALINA_HOME}/conf/server.xml
if [ -s "${CATALINA_HOME}/conf/server.xml" ]; then
    sed -i '/<Connector port=\"8080\" protocol/i\ '"\n${HTTPS_CONNECTOR}"'\n' ${CATALINA_HOME}/conf/server.xml 
    echo "Done:\n ${HTTPS_CONNECTOR}" > ${CATALINA_HOME}/conf/.enabled-https-setup.txt
fi

echo "----------------------------------------------------------------"
echo "---- Setup Tomcat 8 to Use Different HTTP / HTTPS port ----"
echo "----------------------------------------------------------------"
sed -i 's#Connector port="8080"#Connector port="'${TOMCAT_PORT_HTTP}'"#g' ${CATALINA_HOME}/conf/server.xml  
sed -i 's#redirectPort="8443"#redirectPort="'${TOMCAT_PORT_HTTPS}'"#g' ${CATALINA_HOME}/conf/server.xml 

sed -i 's#8080#'${TOMCAT_PORT_HTTP}'#g' ${CATALINA_HOME}/conf/server.xml  
sed -i 's#8443#'${TOMCAT_PORT_HTTPS}'#g' ${CATALINA_HOME}/conf/server.xml  

echo "================== ${CATALINA_HOME}/conf/server.xml ========================="
cat  ${CATALINA_HOME}/conf/server.xml
echo "================== ${CATALINA_HOME}/conf/server.xml.ORIGINAL ========================="
cat  ${CATALINA_HOME}/conf/server.xml.ORIGINAL
echo "================== ${CATALINA_HOME}/webapps/manager/META-INF/context.xml ========================="
cat  ${CATALINA_HOME}/webapps/manager/META-INF/context.xml

#For Tomcat to use https, we need to add a new connector (Tomcat 6 is not configured for SSL by default) and point it to the keystore. To do this, simply add the following lines to your server.xml, found at $CATALINA_HOME/conf/server.xml:

## -- ref: https://protegewiki.stanford.edu/wiki/WebProtegeHttpsLogin

#<-- Define a SSL Coyote HTTP/1.1 Connector on port 443 -->
#<Connector port="443" protocol="HTTP/1.1" SSLEnabled="true"
#               maxThreads="150" scheme="https" secure="true"
#               clientAuth="false" sslProtocol="TLS" keystoreFile="/path/to/my/keystore/.keystore" keystorePass="webprotege"/>

#<!-- Define a SSL Coyote HTTP/1.1 Connector on port 8443 -->
#<Connector
#           protocol="org.apache.coyote.http11.Http11NioProtocol"
#           port="443" maxThreads="200"
#           scheme="https" secure="true" SSLEnabled="true"
#           keystoreFile="${user.home}/.keystore" keystorePass="changeit"
#           clientAuth="false" sslProtocol="TLS"/>
