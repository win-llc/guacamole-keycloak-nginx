#!/bin/bash

/opt/jboss/keycloak/bin/kcadm.sh create realms --server http://localhost:8080/auth --realm master --user admin --password admin -f /tmp/realm-export.json
