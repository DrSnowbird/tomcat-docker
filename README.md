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
set the environment variable `TOMCAT_PASS` to your specific password when running the container:
```
    docker run -d -p 8080:8080 -e TOMCAT_PASS="mypass" openkbs/jre-tomcat
```

You can now test your deployment:

```
    http://127.0.0.1:8080/
```

**reference: https://github.com/tutumcloud/tomcat (much thanks for theirs) **
** by http://openkbs.org **
