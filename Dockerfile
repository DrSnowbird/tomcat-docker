#FROM openkbs/jdk-mvn-py3
FROM openkbs/java11-non-root

MAINTAINER drsnowbird@openkbs.org

USER root

#### ------------------------
#### ---- user: Non-Root ----
#### ------------------------
ENV USER=tomcat
ENV HOME=/home/${USER}

ARG USER_ID=1001
ENV USER_ID=1001

ARG GROUP_ID=1001
ENV GROUP_ID=1001

RUN groupadd -g ${GROUP_ID} ${USER} && \
    useradd -d ${HOME} -s /bin/bash -u ${USER_ID} -g ${USER} ${USER} && \
    usermod -aG root ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p ${HOME} && \
    mkdir -p ${HOME}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown ${USER}:${USER} -R ${HOME} && \
    apt-get clean all
    

##### update ubuntu
RUN apt-get update \
  && apt-get install -yq --no-install-recommends pwgen sudo ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#### -----------------------------
#### ---- Specifications      ----
#### -----------------------------
USER ${USER}
WORKDIR ${HOME}

ENV INSTALL_BASE=${HOME}


#### ====
#### ==== This will be replaced with the latest release from the download site of the product ====
#### ====
ARG PRODUCT_NAME=apache-tomcat

ARG PRODUCT_TAR_GZ_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.12/bin/apache-tomcat-10.0.12.tar.gz
ARG PRODUCT_MAJOR_VERSION=10
ARG PRODUCT_VERSION=10.0.12

ARG PRODUCT_TAR_GZ=${PRODUCT_NAME}-${PRODUCT_VERSION}.tar.gz
ARG PRODUCT_ROOT_DIR=${PRODUCT_NAME}-${PRODUCT_VERSION}

# ARG PRODUCT_TAR_GZ_URL=${PRODUCT_BASE_URL}/tomcat/tomcat-${PRODUCT_MAJOR_VERSION}/v${PRODUCT_VERSION}/bin/apache-tomcat-${PRODUCT_VERSION}.tar.gz
#ARG PRODUCT_BASE_URL=https://dlcdn.apache.org

ENV TOMCAT_MAJOR_VERSION=${PRODUCT_MAJOR_VERSION}
ENV TOMCAT_MINOR_VERSION=${PRODUCT_VERSION}

#ENV CATALINA_HOME=${INSTALL_BASE}/tomcat
ENV CATALINA_HOME=${INSTALL_BASE}/${PRODUCT_NAME}
ENV TOMCAT_HOME=${CATALINA_HOME}/

ARG TOMCAT_HTTPS_ENABLED=${TOMCAT_HTTPS_ENABLED:-1}
ENV TOMCAT_HTTPS_ENABLED=${TOMCAT_HTTPS_ENABLED}

ARG CATALINA_WEBAPPS=${CATALINA_WEBAPPS:-${CATALINA_HOME}/webapps}
ENV CATALINA_WEBAPPS=${CATALINA_WEBAPPS}

## -- Tomcat Console admin (user: tomcat) password --
#NV TOMCAT_PASSWORD=${TOMCAT_PASSWORD:-ChangeMeNow!}

## -- Tomcat HTTPS Keystore password --
###################################################################################################
#### Use Blank password to trigger the Strong Random password for HTTPS -- Highly Recommended! ####
###################################################################################################
ARG KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-}
ENV KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-}

## -- 5.) Product Download: -- ##

#### -----------------------------
#### ---- Download / Install  ----
#### -----------------------------


#### ---- Download URL ---- 
#ENV DOWNLOAD_BASE_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.12/bin
#ENV LATEST_TAR_GZ_URL=${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz
# e.g. https://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz
# https://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.46/bin/apache-tomcat-9.0.46.tar.gz

#RUN wget -q --no-check-certificate ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
## wget -qO- ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \

RUN wget -q --no-check-certificate ${PRODUCT_TAR_GZ_URL} && \
    tar zxf $(basename ${PRODUCT_TAR_GZ_URL}) && \
    ln -s ${HOME}/${PRODUCT_ROOT_DIR} ${CATALINA_HOME} && \
    rm $(basename ${PRODUCT_TAR_GZ_URL})
 
RUN echo "`pwd`" && ls -al ${CATALINA_HOME}

#### -----------------------------
#### ---- Configuration/Setup ----
#### -----------------------------

#RUN sudo chown -R ${USER}:${USER} ${CATALINA_HOME} ${CATALINA_HOME} /docker-entrypoint.sh /launch_tomcat.sh && \

COPY --chown=${USER}:${USER} ./docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=${USER}:${USER} scripts/launch_tomcat.sh /launch_tomcat.sh

COPY --chown=${USER}:${USER} bin/create_tomcat_admin_user.sh ${CATALINA_HOME}/create_tomcat_admin_user.sh
COPY --chown=${USER}:${USER} bin/setup-https-tomcat.sh ${CATALINA_HOME}/setup-https-tomcat.sh

## -- Modify Manager access -- (Don't turn this for production)
COPY config/webapps_manager_META-INF_context.xml ${CATALINA_HOME}/webapps/manager/META-INF/context.xml

RUN chmod +x /docker-entrypoint.sh /launch_tomcat.sh ${CATALINA_HOME}/*.sh

#### ------------------------
#### ---- Ports  :       ----
#### ------------------------
ENV TOMCAT_PORT_HTTP=${TOMCAT_PORT_HTTP:-8080}
ENV TOMCAT_PORT_HTTPS=${TOMCAT_PORT_HTTPS:-8443}
EXPOSE ${TOMCAT_PORT_HTTP}
EXPOSE ${TOMCAT_PORT_HTTPS}

#### ------------------------
#### ---- Start Tomcat:  ----
#### ------------------------
RUN ls -al /docker-entrypoint.sh

USER ${USER}
WORKDIR ${CATALINA_HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/launch_tomcat.sh"]

