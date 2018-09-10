FROM openkbs/jdk-mvn-py3

MAINTAINER openkbs

##### update ubuntu
RUN apt-get update \
  && apt-get install -yq --no-install-recommends pwgen ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV TOMCAT_MAJOR_VERSION=8
ENV TOMCAT_MINOR_VERSION=8.5.33
ENV CATALINA_HOME=/tomcat
ENV TOMCAT_PASS=${TOMCAT_PASS}

WORKDIR /

# INSTALL TOMCAT
#ENV DOWNLOAD_BASE_URL=http://www-us.apache.org/dist
ENV DOWNLOAD_BASE_URL=http://apache.cs.utah.edu
#ENV DOWNLOAD_BASE_URL=http://mirrors.advancedhosters.com/apache

# http://mirrors.advancedhosters.com/apache/tomcat/tomcat-8/v8.5.33/bin/apache-tomcat-8.5.33.tar.gz
# http://apache.cs.utah.edu/tomcat/tomcat-8/v8.5.33/bin/apache-tomcat-8.5.33.tar.gz

RUN echo "${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz"

RUN wget ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
##    wget -qO- ${DOWNLOAD_BASE_URL}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD entry.sh /entry.sh
RUN chmod +x /*.sh

RUN ls -al /

EXPOSE 8080
CMD ["/entry.sh", "run"]
