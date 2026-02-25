FROM quay.io/wildfly/wildfly:latest

# Nombre coincide con el del log de Maven
COPY target/hello-1.0.war /opt/jboss/wildfly/standalone/deployments/ROOT.war

EXPOSE 8080
