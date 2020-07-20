#!/bin/bash

JAVA_HOME=/usr/java/jdk1.8.0_102

LIBS=$(find /opt/ses/currentLibs -name '*.jar' | tr '\n' :)

$JAVA_HOME/bin/java -cp $LIBS \
    com.ubiqube.ses.plugin.administration.SystemAdministrationController "$@"


