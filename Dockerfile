FROM quay.io/wildfly/wildfly:latest

# En este repo, Maven genera el archivo en target/hello-world-war.war
# Lo copiamos como ROOT.war para que sea la página principal
COPY target/hello-world-war.war /opt/jboss/wildfly/standalone/deployments/ROOT.war

EXPOSE 8080
