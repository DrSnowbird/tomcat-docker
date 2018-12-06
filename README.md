# Tomcat 8 + Java JDK 8 + Maven 3 + Python

# Run
-------------------------------------------------
```
    docker run -d -p 8080:8080 openkbs/jre-tomcat
```

To build and run your local image
-------------------------------------------------
First, you need to clone the git:

```
    git clone 
```

To create the image `openkbs/jre-tomcat`, execute the following command:

```
    docker build -t openkbs/jre-tomcat .
```
And, to run

```
    docker run -d -p 8080:8080 openkbs/jre-tomcat
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

## Setting a specific password for the admin account
-------------------------------------------------

If you want to use a preset password instead of a randomly generated one, you can
set the environment variable `TOMCAT_PASSWORD` to your specific password when running the container:
```
    docker run -d -p 8080:8080 -p 8443:8443-e TOMCAT_PASSWORD="mypass" openkbs/jre-tomcat
```

You can now test your deployment for both HTTP and HTTPS:

```
    http://<host_ip>:8080/
    https://<host_ip>:8443/
```

# Customized Build
If you want to build Tomcat's HTTPS to run non-default (8443), e.g., 443 port, you need to build your own image with changing PORTS configuration in either ".env" or "Dockerfile"

# Reference: 
* [Apache Tomcat](https://tomcat.apache.org/)
* [Apache Tomcat8 SSL/TLS Configuration HOW-TO](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)
* [Apache Tomcat change 8080 to 80 port](https://www.baeldung.com/tomcat-change-port)
* [Apache Tomcat Access Denied 403](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)
* [Access tomcat8 Application Manager GUI](https://itpeopleblog.wordpress.com/2018/03/19/access-tomcat8-application-manager-gui/)

# See Also:
* [OpenKbs Jetty Fileserver GIT](https://github.com/DrSnowbird/jetty-fileserver)
* [OpenKbs Jetty Fileserver Hub.docker](https://hub.docker.com/r/openkbs/jetty-fileserver/)


