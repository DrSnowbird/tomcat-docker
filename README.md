# Tomcat 9.0.14 + Java JDK 8 + Maven 3 + Python
[![](https://images.microbadger.com/badges/image/openkbs/jdk-tomcat.svg)](https://microbadger.com/images/openkbs/jdk-tomcat "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/jdk-tomcat.svg)](https://microbadger.com/images/openkbs/jdk-tomcat "Get your own version badge on microbadger.com")

# License Agreement
By using this image, you agree the [Oracle Java JDK License](http://www.oracle.com/technetwork/java/javase/terms/license/index.html).
This image contains [Oracle JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html). You must accept the [Oracle Binary Code License Agreement for Java SE](http://www.oracle.com/technetwork/java/javase/terms/license/index.html) to use this image.

# Components
* java version "1.8.0_201"
  Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
  Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
* Apache Maven 3.6.0
* Python 3.5.2
* node v11.8.0 + npm 6.5.0 (from NodeSource official Node Distribution)
* Gradle 5.1
* Other tools: git wget unzip vim python python-setuptools python-dev python-numpy 

# Run (recommended for easy-start)

```
./run.sh
```

# Run (manually command line)

-------------------------------------------------
```
    docker run -d -p 8080:8080 -p 8443:8443 openkbs/jdk-tomcat
```

To build and run your local image
-------------------------------------------------
First, you need to clone the git:

```
    git clone 
```

To create the image `openkbs/jdk-tomcat`, execute the following command:

```
    docker build -t openkbs/jdk-tomcat .
```
And, to run

```
    docker run -d -p 8080:8080 openkbs/jdk-tomcat
```

The first time that you run your container, a new user `admin` with all privileges
will be created in Tomcat with a random password. To get the password, check the logs
of the container by running:

```
    docker logs <CONTAINER_ID>
```

You will see an output like the following:

    ========================================================================
    You can now connect to this Tomcat server using:

        admin:kjdDkcldjpEW

    Please change the above password as soon as possible!
    =====================================================

In this case, `kjdDkcldjpEW` is the password allocated to the `admin` user.

You can now login to you admin console to configure your tomcat server:

    http://127.0.0.1:8080/manager/html
    http://127.0.0.1:8080/host-manager/html
    http://127.0.0.1:8443/manager/html
    http://127.0.0.1:8443/host-manager/html

* Note: By default the Host Manager is only accessible from a browser running on the same machine as Tomcat (i.e. the Docker Container). If you wish to modify this restriction, you'll need to edit the Host Manager's context.xml file.
    
## Setting a specific password for the admin account
-------------------------------------------------

If you want to use a preset password instead of a randomly generated one, you can
set the environment variable `TOMCAT_PASSWORD` to your specific password when running the container:
```
    docker run -d -p 8080:8080 -p 8443:8443-e TOMCAT_PASSWORD="mypass" openkbs/jdk-tomcat
```

You can now test your deployment for both HTTP and HTTPS:

```
    http://<host_ip>:8080/
    https://<host_ip>:8443/
```

# Customized Build
If you want to build Tomcat's container's internal HTTPS to run non-default (8443), e.g., 443 port, you need to build your own image with changing PORTS configuration in either ".env" or "Dockerfile".
However, for external ports, you can just provide mapping to whatever ports you prefer.

# Reference: 
* [Apache Tomcat](https://tomcat.apache.org/)
* [Apache Tomcat8 SSL/TLS Configuration HOW-TO](https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html)
* [Apache Tomcat change 8080 to 80 port](https://www.baeldung.com/tomcat-change-port)
* [Apache Tomcat Access Denied 403](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)
* [Access tomcat8 Application Manager GUI](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)

# See Also:
* [OpenKbs Jetty Fileserver GIT](https://github.com/DrSnowbird/jetty-fileserver)
* [OpenKbs Jetty Fileserver Hub.docker](https://hub.docker.com/r/openkbs/jetty-fileserver/)

# Release Information:
```
tomcat@0da698eab080:~$ /usr/printVersions.sh 
+ echo JAVA_HOME=/usr/java
JAVA_HOME=/usr/java
+ java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
+ mvn --version
Apache Maven 3.6.0 (97c98ec64a1fdfee7767ce5ffb20918da4f719f3; 2018-10-24T18:41:47Z)
Maven home: /usr/apache-maven-3.6.0
Java version: 1.8.0_201, vendor: Oracle Corporation, runtime: /usr/jdk1.8.0_201/jre
Default locale: en_US, platform encoding: ANSI_X3.4-1968
OS name: "linux", version: "4.15.0-43-generic", arch: "amd64", family: "unix"
+ python -V
Python 2.7.12
+ python3 -V
Python 3.5.2
+ pip --version
pip 19.0.1 from /usr/local/lib/python3.5/dist-packages/pip (python 3.5)
+ pip3 --version
pip 19.0.1 from /usr/local/lib/python3.5/dist-packages/pip (python 3.5)
+ gradle --version

Welcome to Gradle 5.1.1!

Here are the highlights of this release:
 - Control which dependencies can be retrieved from which repositories
 - Production-ready configuration avoidance APIs

For more details see https://docs.gradle.org/5.1.1/release-notes.html


------------------------------------------------------------
Gradle 5.1.1
------------------------------------------------------------

Build time:   2019-01-10 23:05:02 UTC
Revision:     3c9abb645fb83932c44e8610642393ad62116807

Kotlin DSL:   1.1.1
Kotlin:       1.3.11
Groovy:       2.5.4
Ant:          Apache Ant(TM) version 1.9.13 compiled on July 10 2018
JVM:          1.8.0_201 (Oracle Corporation 25.201-b09)
OS:           Linux 4.15.0-43-generic amd64

+ npm -v
6.5.0
+ node -v
v11.8.0
+ cat /etc/lsb-release /etc/os-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.3 LTS"
NAME="Ubuntu"
VERSION="16.04.3 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.3 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
VERSION_CODENAME=xenial
UBUNTU_CODENAME=xenial
```

