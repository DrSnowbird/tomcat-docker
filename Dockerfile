FROM openkbs/jdk-mvn-py3

MAINTAINER drsnowbird@openkbs.org

USER root

##### update ubuntu
RUN apt-get update \
  && apt-get install -yq --no-install-recommends pwgen sudo ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#### -----------------------------
#### ---- Specifications      ----
#### -----------------------------
ARG INSTALL_BASE=${INSTALL_BASE:-/opt}

ENV TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION:-9}
ENV TOMCAT_MINOR_VERSION=${TOMCAT_MINOR_VERSION:-9.0.54}

ENV CATALINA_HOME=${INSTALL_BASE}/tomcat
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

#### -----------------------------
#### ---- Download / Install  ----
#### -----------------------------

WORKDIR ${INSTALL_BASE}

#### ---- Download URL ---- 
ENV DOWNLOAD_BASE_URL=https://dlcdn.apache.org

# https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.46/bin/apache-tomcat-9.0.54.tar.gz
RUN wget -q --no-check-certificate ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    ## wget -qO- ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

#### -----------------------------
#### ---- Configuration/Setup ----
#### -----------------------------
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY scripts/launch_tomcat.sh /launch_tomcat.sh

COPY bin/create_tomcat_admin_user.sh ${CATALINA_HOME}/create_tomcat_admin_user.sh
COPY bin/setup-https-tomcat.sh ${CATALINA_HOME}/setup-https-tomcat.sh

## -- Modify Manager access -- (Don't turn this for production)
COPY config/webapps_manager_META-INF_context.xml ${CATALINA_HOME}/webapps/manager/META-INF/context.xml

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
    
RUN sudo chown -R ${USER}:${USER} ${CATALINA_HOME} /docker-entrypoint.sh

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

