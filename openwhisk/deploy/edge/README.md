# OPENWHISK -  EDGE DEPLOYMENT

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Bash Script](#bash-script)
3. [Values File and Deployed Services](#values-file-and-deployed-services)


## Introduction

This folder contains some files to develop the edge solution based on Openwhisk.

You will find two files and two folders:
1. [deploy.sh]: the script to be executed to deploy the edge solution.
2. [values.yaml]: the value file used to deploy the helm chart related to the edge solution.
3. [sensors]: the folder containing the code to configure and allow the sensors to send data to the MQTT provider.
4. [install-tools]: the folder containing some scripts to install tools required for the installation.


## Bash Script

To deploy the central solution, we must run the following command inside this folder:

```
./deploy.sh <namespace-name>
```

The script does several things: 

1. It sets the parameters in the [values.yaml](./values.yaml) file, exploting the parameters of the [parameters.yml](./../parameters/parameters.yml) file, additional cluster informations and other parameters that will be used to configure the actions, triggers ecc...
2. It creates the provided namespace
3. It adds the chartmuseum repository for helm charts
4. It deploys the helm chart relative to the edge solution, using the [values.yaml](./values.yaml) file.



## Values File and Deployed Services

The deployed chart is composed by multiple subcharts, it particular it includes:

1. OpenWhisk and all its related services
2. The InfluxDB database, used to store local data sent by sensors
3. Mosquitto 
4. MQTT provider, to add, modify and delete triggers that are listening on MQTT topics.

The chart is retrieved from the chartmuseum helm repository and its subcharts are also stored in that, excluding the InfluxDB one. 

The [values.yaml](./values.yaml) file has different sections, which are obviously related to the different subcharts.

**SOME VALUES ARE ALREADY SET IN THE VALUES FILE AND ARE NOT GOING TO BE TOUCHED BY THE SCRIPT, WHILE OTHER VALUES ARE GOING TO BE MODIFIED ACCORDING TO WHAT IS PROVIDED IN THE FILE [PARAMATERS.YML](./../parameters/parameters.yml)**

The following section will explain the critical values that can be found in [values.yaml](./values.yaml) and what they are going to contain.

The fields are:

- `openwhisk.auth.guest`: This field specifies the guest authentication key for OpenWhisk.
- `openwhisk.whisk.ingress.apiHostName`: This field contains the Cluster's Master Node IP.
- `openwhisk.whisk.ingress.apiHostName`: This field contains the Node Port on which the OpenWhisk API Host will be exposed.
- `openwhisk.db.external`: This field specifies if the CouchDB has already been created or not. It is set to *true*.
- `openwhisk.db.wipeAndInit`: This field specifies if the CouchDB instance will be initialized from zero. In this case, the field should is set to *false*.
- `openwhisk.db.host`: This field specifies the hostname of the CouchDB instance used by OpenWhisk. This field is compliant with the one specified in the CouchDB values. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `openwhisk.db.auth.username`: This field specifies the username used to authenticate with CouchDB. **This field is compliant with the one specified in the CouchDB values of the centralized instance**
- `openwhisk.db.auth.password`: This field specifies the password used to authenticate with CouchDB. **This field is compliant with the one specified in the CouchDB values of the centralized instance**
- `openwhisk.db.port`: This field specifies the port number used by the CouchDB instance. **In particular, in the edge instance, the port is 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `openwhisk.db.protocol`: This field specifies the protocol used by the CouchDB instance.  **In particular, in the edge instance, the protocol should be HTTPS, since the database is deployed outside the cluster and we need a secure protocol to contact it**.
- `openwhisk.providers.kafka.enabled`: This field specifies if the kafka provider is enabled, and it is set to *false*.


- `influxdb2.adminUser.user`: This field specifies the username of the InfluxDB administrator.
- `influxdb2.adminUser.password`: This field specifies the password of the InfluxDB administrator.
- `influxdb2.adminUser.token`: This field specifies the authentication token used to connect to InfluxDB.
- `influxdb2.adminUser.organization`: This field specifies the organization used by InfluxDB.
- `influxdb2.adminUser.bucket`: This field specifies the bucket used by InfluxDB.
- `influxdb2.iroute.externalUrl`: This field specifies the external URL used by InfluxDB.

- `.mosquitto.auth.users[0].username`: the username for the first user in the list of MQTT users.
- `.mosquitto.auth.users[0].password`: the password for the first user in the list of MQTT users. The password is expected to be already encrypted.
- `.mosquitto.service.mqttPort`: the MQTT port that the Mosquitto service listens on.

- `.mqtt-provider.provider.providerPort`:  the port number that the Mosquitto provider listens on.
- `.mqtt-provider.provider.couchdbUsername`: the username for the CouchDB instance used by Mosquitto. **It is should be consistent with the CouchDB username provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbPassword`: sets the password for the CouchDB instance used by Mosquitto. **It is consistent with the CouchDB password provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbGateway` : sets the gateway address for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `.mqtt-provider.provider.couchdbExtPort`: sets the external port number for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the port is 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `.mqtt-provider.openwhisk.apiHost`: sets the API host for OpenWhisk, which is used by Mosquitto. **It is consistent with the local OpenWhisk API Host, which is set in the values file**.

Persistence is enabled for both InfluxDB and Mosquitto in the values file.









