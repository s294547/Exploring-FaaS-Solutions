# EDGE CHART- CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [InfluxDB](#influxdb)
3. [OpenWhisk](#openwhisk)
4. [Mosquitto](#mosquitto)
5. [MQTT Provider](#mqtt-provider)
6. [Values](#values)



## Introduction

This chart is a chart that is used to deploy the edge solution based on OpenWhisk realted to my master thesis work. It is a chart composed by different subcharts, which will be all presented.

This chart is provided to deploy the edge solution based on OpenWhisk, which should include: 
1. An OpenWhisk instance, which uses a remote CouchDB instance that should have been already deployed.
2. A local InfluxDB database, which should keep the data sent by sensors
3. Mosquitto, to handle messages published on MQTT. 
4. MQTT provider, to handle the creation, modification and elimination of triggers that are fired when a message is published on a certain MQTT topic. It is also responsible of firing the triggers.

 


## InfluxDB
The chart has an influxdb2 subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add influxdata https://helm.influxdata.com/
helm pull influxdata/influxdb2
```
This chart is the standard InfluxDB chart.

## OpenWhisk

The chart has an openwhisk subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/openwhisk
```

This chart is an extension of the standard Apache OpenWhisk helm chart. This OpenWhisk instance should be set to use an external couchdb database and not to initialize it. 

## Mosquitto 

The chart has a mosquitto chart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/mosquitto
```
This chart is an extension of the standard Mosquitto chart.

## MQTT provider

## MQTT Provider
The chart deploys an OpenWhisk MQTT provider, it can be retrieved using those commands: 

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/mqtt-provider
```

This chart is a chart deploying a MQTT provider for OpenWhisk, based on the solution provided [here](https://blog.zhaw.ch/splab/2019/03/15/building-a-sample-mqtt-based-application-on-openwhisk/). 

## Values

This section will explain the critical values that can be found in [values.yaml](./values.yaml) and the recommended values when deploying this chart for an environment kindred to my master thesis' environment.

The fields are:

- `openwhisk.auth.guest`: This field specifies the guest authentication key for OpenWhisk.
- `openwhisk.whisk.ingress.apiHostName`: This field should contain the Cluster's Master Node IP.
- `openwhisk.whisk.ingress.apiHostName`: This field should contain the Node Port on which the OpenWhisk API Host will be exposed.
- `openwhisk.db.external`: This field specifies if the CouchDB has already been created or not. It Should be set to *true*.
- `openwhisk.db.wipeAndInit`: This field specifies if the CouchDB instance will be initialized from zero. In this case, the field should be set to *false*.
- `openwhisk.db.host`: This field specifies the hostname of the CouchDB instance used by OpenWhisk. This field should be compliant with the one specified in the CouchDB values. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `openwhisk.db.auth.username`: This field specifies the username used to authenticate with CouchDB. **This field should be compliant with the one specified in the CouchDB values of the centralized instance**
- `openwhisk.db.auth.password`: This field specifies the password used to authenticate with CouchDB. **This field should be compliant with the one specified in the CouchDB values of the centralized instance**
- `openwhisk.db.port`: This field specifies the port number used by the CouchDB instance. **In particular, in the edge instance, the port should be 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `openwhisk.db.protocol`: This field specifies the protocol used by the CouchDB instance.  **In particular, in the edge instance, the protocol should be HTTPS, since the database is deployed outside the cluster and we need a secure protocol to contact it**.
- `openwhisk.providers.kafka.enabled`: This field specifies if the kafka provider is enabled, and should be  set to *false*.


- `influxdb2.adminUser.user`: This field specifies the username of the InfluxDB administrator.
- `influxdb2.adminUser.password`: This field specifies the password of the InfluxDB administrator.
- `influxdb2.adminUser.token`: This field specifies the authentication token used to connect to InfluxDB.
- `influxdb2.adminUser.organization`: This field specifies the organization used by InfluxDB.
- `influxdb2.adminUser.bucket`: This field specifies the bucket used by InfluxDB.
- `influxdb2.iroute.externalUrl`: This field specifies the external URL used by InfluxDB.

- `.mosquitto.auth.users[0].username`: sets the username for the first user in the list of MQTT users.
- `.mosquitto.auth.users[0].password`: sets the password for the first user in the list of MQTT users. The password is expected to be already encrypted.

- `.mqtt-provider.service.mqttPort`: sets the MQTT port that the MQTT provider service listens on.
- `.mqtt-provider.provider.providerPort`: sets the port number that the MQTT provider provider listens on.
- `.mqtt-provider.provider.couchdbUsername`: sets the username for the CouchDB instance used by MQTT provider. **It should be consistent with the CouchDB username provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbPassword`: sets the password for the CouchDB instance used by MQTT provider. **It should be consistent with the CouchDB password provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbGateway` : sets the gateway address for the CouchDB instance used by MQTT provider. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `.mqtt-provider.provider.couchdbExtPort`: sets the external port number for the CouchDB instance used by MQTT provider. **In particular, in the edge instance, the port should be 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `.mqtt-provider.openwhisk.apiHost`: sets the API host for OpenWhisk, which is used by MQTT provider. **It should be consistent with the local OpenWhisk API Host, which is set in the values file**.

It is important to enable persistence for both InfluxDB and Mosquitto.