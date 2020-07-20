#!/bin/bash
#set -x

[ -f /opt/jboss/tmp ] && rm -rf /opt/jboss/tmp
mkdir /opt/jboss/tmp
cp /opt/jboss/wildfly/standalone/deployments/ubi-api.ear /opt/jboss/wildfly/standalone/deployments/ubi-api.ear.bak
cp /opt/jboss/wildfly/standalone/deployments/ubi-api.ear /opt/jboss/tmp
cd /opt/jboss/tmp
unzip ubi-api.ear
rm -f ubi-api.ear
mkdir device
cp /opt/ubi-jentreprise/resources/templates/conf/device/custom/* device
ls -la
ls -la lib
jar uf  lib/ubi-api-properties.jar  device/manufacturers.properties
jar uf  lib/ubi-api-properties.jar  device/models.properties
jar -cvf ubi-api.ear META-INF/application.xml
mv ubi-api.ear /opt/jboss/wildfly/standalone/deployments/