# MANO 

## MANO keycloak configuration
In this readme, you are going to understand how to import (e.g: `mano-realm`)  on-starting of the keycloak service instance `mano-auth`.


### Purpose
- Automatize the minimum keycloak settings in order to deploy and manage a VNFM and NFVO.
- Simplify the INTERNAL (e.g: QA, DEV, PRE-SALES) deployment from scratch of the MANO.

### Dependencies
There are two dependencies required beforehand: 
- MSA docker project: [msa-docker](http:/https://github.com/ubiqube/msa-docker/ "msa-docker")
- Keycloak configurations to be imported:

```shell
./lab/mano/config/keycloak/mano-realm-realm.json
./lab/mano/config/keycloak/mano-realm-users-0.json
```

- The docker compose including the import of the realm to the keycloak service:
		./lab/mano/docker-compose.mano.override.yml

### Import MANO realm 
The `mano-realm` is going to be imported during the `MSA` and `MANO` docker services deployment.

Check this section about  [How to run msa-docker](http://https://github.com/ubiqube/msa-docker#how-to-run-msa-docker "How to run msa-docker").

Otherwise, you can find below the command allow you to deploy the MSA and MANO docker services. It will start keycloak by import the `mano-realm`.

```shell
docker compose -f ./docker-compose.yml -f ./lab/mano/docker-compose.mano.yml -f ./lab/mano/docker-compose.mano.override.yml up -d

```

Once the services are started. Open your favorite browser and connect to keycloak http://YOUR_MSA_IP_ADDRESS:8110/auth/.

Confirm that the realm is successfully imported, you must see the listed object in your keycloak server:
- Realm: `mano-realm`  (click-on this realm)
- Clients: `mano-nfvo` and `mano-vnfm`
- Realm roles: `NFVO` and `VNFM`

> NOTE: The client id and secret is unchanged every time you import this same realm configuration.

Then, use the `client-id` and `client secret` to request tokens to your keycloak to get authentified to your NFVO or VNFM.

### References

- [Keycloak - Importing and Exporting Realms](http://https://www.keycloak.org/server/importExport "Keycloak - Importing and Exporting Realms")
