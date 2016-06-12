#!/bin/bash -x

if [ $# -gt 0 ]; then
    docker run -d -p 8080:8080 -e TOMCAT_PASS="$1" openkbs/jre-tomcat
else
    docker run -d -p 8080:8080 openkbs/jre-tomcat
fi

