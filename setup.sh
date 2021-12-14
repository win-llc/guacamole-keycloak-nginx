#!/bin/bash -x

echo "checking for patch"
patch -v
echo "checking for wget"
wget -v
echo "checking for docker-compose"
docker-compose -v
echo "checking for docker"
docker -v
echo "checking for keytool"
keytool -v

# create directories
mkdir -p {data/guacamole,data/keycloak,init,openid} 

cd openid

wget -nc https://mirrors.ocf.berkeley.edu/apache/guacamole/1.3.0/binary/guacamole-auth-openid-1.3.0.tar.gz
tar -xf guacamole-auth-openid-1.3.0.tar.gz
mv guacamole-auth-openid-1.3.0/* .
cd ..

# create the database initialization script for the guacamole database
docker run --rm \
  docker.io/guacamole/guacamole:1.3.0 \
    /opt/guacamole/bin/initdb.sh --postgres > init/initdb.sql.orig

cp init/initdb.sql.orig init/initdb.sql

patch init/initdb.sql < config/guacamole/1.add-guacadmin-email.patch

# get the original server.xml
touch init/server.xml.orig
docker run --rm --name guacamole-setup \
  docker.io/guacamole/guacamole:1.3.0 \
  cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

# make a copy to patch
cp init/server.xml.orig init/server.xml

# enable ssl, and such
patch init/server.xml < config/guacamole/0.enable-tomcat-ssl.patch

# Need self-signed cert for ca

# Create private keys for:
#   Guacamole
#   Keycloak

openssl req \
  -newkey rsa:2048 \
  -nodes \
  -keyout init/guacamole.key \
  -x509 \
  -days 365 \
  -out init/guacamole.crt \
  -subj "/C=US/ST=VA/L=Alexandria/O=WIN LLC/OU=Dev/CN=guac-keycloak.winllc-dev.com"
  -addext "subjectAltName = DNS:guac-keycloak.winllc-dev.com" \

# values pulled from server.xml within the image, and errors from the docker log
keytool -genkey \
  -alias server \
  -keyalg RSA \
  -keystore init/application.keystore \
  -keysize 2048 \
  -storepass password \
  -dname "cn=keycloak-guac.winllc-dev.com, ou=Dev, o=WIN LLC, c=US" \
  -ext "SAN=DNS:keycloak-guac.winllc-dev.com" \
  -keypass password \
  -trustcacerts \
  -validity 365

# make the certificate available to guacamole
touch init/keycloak.crt
keytool -exportcert \
  -keystore init/application.keystore \
  -alias server \
  -storepass password \
  -keypass password | \
  openssl x509 -inform der -text > init/keycloak.crt

# Grabbing cacerts, don't use this for standalone.xml
# as we don't link to postgres
touch init/cacerts
timeout 20 docker run --rm --name keycloak-cacerts -e DB_VENDOR=h2 docker.io/jboss/keycloak:15.0.2 &
sleep 1s
docker cp keycloak-cacerts:/etc/pki/ca-trust/extracted/java/cacerts init/cacerts

keytool -importcert \
  -alias keycloak \
  -keystore init/cacerts \
  -storepass changeit \
  -file init/keycloak.crt \
  -trustcacerts -noprompt 
keytool -importcert \
  -alias guacamole \
  -keystore init/cacerts \
  -storepass changeit \
  -file init/guacamole.crt \
  -trustcacerts -noprompt

keytool -importcert \
  -alias windows-ca \
  -keystore init/cacerts \
  -storepass changeit \
  -file windows-ad-trust.cer \
  -trustcacerts -noprompt

docker stop keycloak-cacerts
