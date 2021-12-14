# ###############################
# Notice: (Retiring this project)
# PLEASE: use the newer project:
# => DrSnowbird/tomcat-docker
# ###############################

Apache Tomcat 9 + Java OpenJDK 11 + Maven 3 + Python 3
[![](https://images.microbadger.com/badges/image/openkbs/jdk-tomcat.svg)](https://microbadger.com/images/openkbs/jdk-tomcat "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/jdk-tomcat.svg)](https://microbadger.com/images/openkbs/jdk-tomcat "Get your own version badge on microbadger.com")

# Components:

* [Base Container Image: openkbs/java11-non-root3](https://github.com/DrSnowbird/java11-non-root)
* [Apache Tomcat 10](https://tomcat.apache.org/download-10.cgi)

# Frist, clone the github git

```
    git clone https://github.com/DrSnowbird/jdk-tomcat.git
```

# NOTICE: Due to docker.hub.io not allowing free hosting anymore, you have to make your local build including the parent images:
- [DrSnowbird/java11-non-root](https://github.com/DrSnowbird/java11-non-root), [GIT](git@github.com:DrSnowbird/java11-non-root.git)
For older version, the parent Container images are either of these two below:
- [DrSnowbird/jdk11-mvn-py3](https://github.com/DrSnowbird/jdk11-mvn-py3), [GIT](git@github.com:DrSnowbird/jdk11-mvn-py3.git)
- [DrSnowbird/jdk-mvn-py3](https://github.com/DrSnowbird/jdk-mvn-py3), [GIT](git@github.com:DrSnowbird/jdk-mvn-py3.git)

# Build
You can build your own image locally.
```
./build.sh
```

# Run (recommended for easy-start)

```
./run.sh
```
Then, open Web Browser: login `tomcat` (or `admin`) with default password, `password`
```
    http://<host_ip>:18880/
    or
    https://<host_ip>:18443/
```

# Run (manually command line)

-------------------------------------------------
```
    docker run -d -p 18880:8080 -p 18443:8443 openkbs/jdk-tomcat
```

# Build and run your local image
To create the image `openkbs/jdk-tomcat` (or change to your own name, e.g. `my/jdk-tomcat`), execute the following command:

```
    docker build -t openkbs/jdk-tomcat .
```
And, to run

```
    docker run -d -p 18880:8080 -p 18443:8443 openkbs/jdk-tomcat
```

The first time that you run your container, a new user `admin (or tomcat)` with default password `ChangeMeNow!` with all privileges will be created in Tomcat.
However, it the password is not provided, then a random password will be generated. To get the random password, check the docker logs of the container by running:

```
    docker logs <CONTAINER_ID>
    (Loook for `TOMCAT_PASSWORD` at very beginning of the log file)
```
Or,
```
    ./logs.sh |grep -i TOMCAT_PASSWORD
    
    >>> (see somthing like this):
    TOMCAT_PASSWORD=ChangeMeNow!
```

You can now login to you admin console to configure your tomcat server:

    http://127.0.0.1:18880/manager/html
    http://127.0.0.1:18880/host-manager/html
    http://127.0.0.1:18443/manager/html
    http://127.0.0.1:18443/host-manager/html

* Note: By default the Host Manager is only accessible from a browser running on the same machine as Tomcat (i.e. the Docker Container). If you wish to modify this restriction, you'll need to edit the Host Manager's context.xml file.
    
# Deploy a WAR file
You can deploy additional WAR files in this Docker Container.
To deploy an WAR file, first make sure that you already started container and then just drop your WAR file into the `./deploy` directory, then run the command below. You can deploy multiple WAR files by drop all of them into the deploy directory.
```
./deploy.sh
```

# Setting a specific password for the admin account
-------------------------------------------------

If you want to use a preset password instead of a randomly generated one, you can
set the environment variable `TOMCAT_PASSWORD` to your specific password when running the container:
```
    docker run -d -p 8080:8080 -p 8443:8443-e TOMCAT_PASSWORD="mypass" openkbs/jdk-tomcat
```

You can now test your deployment for both HTTP and HTTPS:

```
    http://<host_ip>:18880/
    https://<host_ip>:18443/
```

# Customized Configuration
If you want to build Tomcat's container's internal HTTPS to run non-default (8443), e.g., 443 port, you need to build your own image with your customized PORTS configuration in Tomcat configuration files and modify the "Dockerfile" ports corresponding.
However, for external ports, you can just provide mapping to whatever internal ports you change to.

# Reference: 
* [Apache Tomcat](https://tomcat.apache.org/)
* [Apache Tomcat8 SSL/TLS Configuration HOW-TO](https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html)
* [Apache Tomcat change 8080 to 80 port](https://www.baeldung.com/tomcat-change-port)
* [Apache Tomcat Access Denied 403](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)
* [Access tomcat8 Application Manager GUI](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)

# See Also:
* [OpenKbs Jetty Fileserver GIT](https://github.com/DrSnowbird/jetty-fileserver)
* [OpenKbs Jetty Fileserver Hub.docker](https://hub.docker.com/r/openkbs/jetty-fileserver/)

# Releases information
* [See Releases Information](https://github.com/DrSnowbird/jdk-mvn-py3#releases-information)

