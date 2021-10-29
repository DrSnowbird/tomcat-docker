#!/bin/bash

MAJOR_VERSION=10

# https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.12/bin/apache-tomcat-10.0.12.tar.gz
PRODUCT_TAR_GZ_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.12/bin/apache-tomcat-10.0.12.tar.gz
PRODUCT_TAR_GZ=apache-tomcat-10.0.12.tar.gz
PRODUCT_MAJOR_VERSION=10
PRODUCT_VERSION=10.0.12
PRODUCT_ROOT_DIR=apache-tomcat-10.0.12
# (not used)
PRODUCT_BASE_URL=https://dlcdn.apache.org

function get_PRODUCT_release_tomcat() {
    ## -- you need to manual modify this lin to match the latest download URL specifics.
    PRODUCT_TAR_GZ_URL=`curl --silent https://tomcat.apache.org/download-${MAJOR_VERSION}.cgi|grep "apache-tomcat-10"|grep "tar.gz"|head -n 1|cut -d'"' -f2`
    PRODUCT_TAR_GZ=$(basename ${PRODUCT_TAR_GZ_URL})
    __TAR_GZ_LATEST=`echo ${PRODUCT_TAR_GZ}|cut -d'-' -f3`
    PRODUCT_VERSION=${__TAR_GZ_LATEST%%.tar.gz}
    PRODUCT_MAJOR_VERSION=${PRODUCT_VERSION%.*.*}
    PRODUCT_BASE_URL=`echo $(dirname ${PRODUCT_TAR_GZ_URL})|cut -d'/' -f1-3`
    PRODUCT_ROOT_DIR=${PRODUCT_TAR_GZ%%.tar.gz}
}
get_PRODUCT_release_tomcat

echo -e "-----------------------------------"
echo -e "PRODUCT_TAR_GZ_URL=${PRODUCT_TAR_GZ_URL}"
echo -e "PRODUCT_TAR_GZ=$PRODUCT_TAR_GZ"
echo -e "PRODUCT_MAJOR_VERSION=$PRODUCT_MAJOR_VERSION"
echo -e "PRODUCT_VERSION=$PRODUCT_VERSION"
echo -e "PRODUCT_ROOT_DIR=$PRODUCT_ROOT_DIR"
echo -e "-----------------------------------"


CONFIG_FILE=${1:-./Dockerfile}
CONFIG_KEY="PRODUCT_VERSION"
CONFIG_VALUE=${PRODUCT_VERSION}

function replaceValueInConfig() {
    FILE=${1}
    KEY=${2}
    VALUE=${3}
    #sed -i 's#^ENV[[:blank:]]*'$KEY'[[:blank:]]*=.*/ENV '$KEY'='$VALUE'#gm' $FILE
    #sed -i 's#^ARG[[:blank:]]*'$KEY'[[:blank:]]*=.*#ARG '$KEY'='$VALUE'#gm' $FILE
    sed -i 's#^\(ARG\|ENV\)[[:blank:]]*'$KEY'[[:blank:]]*=.*#\1 '$KEY'='"$VALUE"'#gm' $FILE
    echo "results (after replacement) with new value:"
    cat $FILE |grep "${CONFIG_KEY}"
}

#ARG PRODUCT_MAJOR_VERSION=10
replaceValueInConfig ${CONFIG_FILE} "PRODUCT_MAJOR_VERSION" ${PRODUCT_MAJOR_VERSION}

#ARG PRODUCT_VERSION=10.0.12
replaceValueInConfig ${CONFIG_FILE} "PRODUCT_VERSION" ${PRODUCT_VERSION}

#ARG PRODUCT_TAR_GZ_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.12/bin/apache-tomcat-10.0.12.tar.gz
replaceValueInConfig ${CONFIG_FILE} "PRODUCT_TAR_GZ_URL" ${PRODUCT_TAR_GZ_URL}

make build
