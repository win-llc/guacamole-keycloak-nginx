# guacamole-keycloak-nginx
Docker compose project with keycloak and guacamole. Based off of https://github.com/cynthia-rempel/guacamole-compose

By default the Lab realm in Keycloak is configured to use email authentication by implementing keycloak-otp-login (https://github.com/intensiongmbh/keycloak-otp-login)

## To get started with no configurations, run 

```
(Optional) If you will be connecting Keycloak to Active Directory, add relevant 
LDAPS Trust Certificates into config/trust/<file>.cer

export SERVER_FQDN=<your server FQDN>

source ./setup.sh

NOTE: Copy the Keycloak Admin Password that is output. Use this to login with the 'admin' account.

docker-compose up
```

## Add Domain Admin Group as Guacamole System Administrator
```
docker cp config/guacamole/add-domain-admin-group.sql guacamole-keycloak-nginx_postgres_1:/tmp/add-domain-admin-group.sql
docker exec -i -e PGPASSWORD=some_password guacamole-keycloak-nginx_postgres_1 psql postgresql://guacamole_user:some_password@localhost:5432/guacamole_db -f tmp/add-domain-admin-group.sql
```

## To customize:

Find all instances of winllc-dev.com, and replace them to you're liking

```
grep -R winllc-dev.com | grep -v Binary
```

## To use

Then browse to:

https://<host.domain>:8443/guacamole

https://<host.domain>:8443/auth

### To configure Active Directory
In Keycloak, modify the connection settings for the 'Active Directory' connection in User Federation.

Once the updates have been saved, click 'Synchronize all users'

### To use Email Authentication
Configure the SMTP settings for the 'Lab' Realm in Keycloak

### To add users

---

Guacamole uses keycloak for identity, and uses postgres for authorization.

```
Guacamole's OpenID Connect ... removing the need for users to log into Guacamole
directly. This module must be layered on top of ... that provide connection
information ... database authentication ....
```

Because of this, ***users have to be added to both keycloak and postgres.***

Reference: https://guacamole.apache.org/doc/gug/openid-auth.html

---

#### Adding a user to Postgres

To add users to postgres, add them through the guacamole application.

https://<host.domain>:8443/guacamole

username: *guacadmin@guacadmin*

password: *guacadmin*

---

**Upper right corner, username, settings**

![Upper right corner, username, settings](docs/images/0-guacamole-settings.png "Upper right corner, username, settings")

---

**Middle top, users, left middle, new user**

![Middle top, users, left middle, new user](docs/images/1-add-users.png "Middle top, users, left middle, new user")

---

**Make sure the username is in email format, make appropriate selections**

![Make sure the username is in email format, make appropriate selections](docs/images/2-userprofile-a.png "Make sure the username is in email format, make appropriate selections")

---

**Scroll down, continuing to make appropriate selections, then click save**

![Scroll down, continuing to make appropriate selections, then click save](docs/images/3-userprofile-b.png "Scroll down, continuing to make appropriate selections, then click save")

***NOTE***: if a connection is under a subgroup, both the subgroup and
connection must be checked for the user to create a connection.

---

#### Adding user to Keycloak

https://<host.domain>:8443/auth

Administration Console

---

**Scroll down, click users, view all users, add user**

![Scroll down, click users, view all users, add user](docs/images/4-add-users-keycloak.png "Scroll down, click users, view all users, add user")

---

**Make the keycloak user's email match the username and email of guacamole user**

![Make the keycloak user's email match the username and email of guacamole user](docs/images/5-userprofilea-keycloak.png "Make the keycloak user's email match the username and email guacamole user")

***NOTE***: The email of the keycloak user must match the username and email of the guacamole user.

---

**Set the password**

![Set the password](docs/images/6-set-password-keycloak.png "Set the password")

*Why doesn't keycloak let you set the password when you create the user ?!?*

---

## Adding Connections

---

**Upper right corner, username, settings**

![Upper right corner, username, settings](docs/images/0-guacamole-settings.png "Upper right corner, username, settings")

---

**Middle top, connections, left, new connection**

![Middle top, connections, left, new connection](docs/images/1-new-connection.png "Middle top, connections, left, new connection")

---

**Make an SSH connection**

- *Name*: some-name

- *Location*: the-group

- *Protocol*: *SSH*

- *Max number of connections*: 2

- *Max number of connections per user*: 2

Reference: https://jasoncoltrin.com/2017/10/04/setup-guacamole-remote-desktop-gateway-on-ubuntu-with-one-script/

![Protocol SSH](docs/images/2-new-connection-ssh-a.png "Protocol SSH")

---

**Set the host**

**Scroll Down**, under the Network Section set the host

![Set the host and port](docs/images/3-new-connection-ssh-b.png "Set the host and port")

**CLICK SAVE **
---

## Where to send users when you want to tell them RTFM

https://guacamole.apache.org/doc/gug/using-guacamole.html

## To uninstall

```
docker-compose down
./teardown.sh
```

## Reference:

  - https://github.com/airaketa/guacamole-docker-compose/tree/5aac1dccbd7b89b54330155270a4684829de1442
  - https://lemonldap-ng.org/documentation/latest/applications/guacamole
https://guacamole.apache.org/doc/gug/administration.html#connection-management
  - https://jasoncoltrin.com/2017/10/04/setup-guacamole-remote-desktop-gateway-on-ubuntu-with-one-script/
