# CENTRAL CHART - CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [CouchDB](#couchdb)
3. [Grafana](#grafana)
4. [Grafana Operator](#grafana-operator)
5. [InfluxDB](#influxdb)
6. [OpenWhisk](#openwhisk)
7. [MQTT Provider](#mqtt-provider)
8. [Values](#values)


## Introduction

This chart is a chart that is used to deploy the central solution based on OpenWhisk realted to my master thesis work. It is a chart composed by different subcharts, which will be all presented.

This chart is provided to deploy the centralized solution based on OpenWhisk, which should include: 
1. An OpenWhisk instance
2. A CouchDB database shared between the local and edge OpenWhisk instances to store all their data
3. A centralized InfluxDB database, which should keep the aggregates 
4. Grafana and Grafana Operator, in order to deploy a Grafana Dashboard to monitor the aggregate data sent by edge instances. 
5. A MQTT provider, to handle the creation, modification and elimination of triggers that are fired when a message is published on a certain MQTT topic.
 
## CouchDB
 
The chart has a couchdb subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/couchdb
```

This chart is an extension of the standard Apache CouchDB chart, providing a Traefik Ingress Route to expose the service outside the cluster. This option can be disabled or enabled in the values file.

## Grafana 
The chart has a grafana subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/grafana
```

This chart, if the values are opportunely set, can deploy a Grafana Data Source of type InfluxDB and a Grafana Dashboard to show the aggregate data that can be founf in the InfluxDB.

## Grafana Operator
The chart has a grafana operator subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/grafana-operator
```

## InfluxDB
The chart has an influxdb2 subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/influxdb2
```
This chart is an extension of the standard InfluxDB chart, providing a Traefik Ingress Route to expose the service outside the cluster. This option can be disabled or enabled in the values file.

## OpenWhisk
The chart has an openwhisk subchart, in particular the chart that can be retrieved using those commands:

```
helm repo add chartmuseum https://chart.liquidfaas.cloud
helm pull chartmuseum/openwhisk
```

This chart is an extension of the standard Apache OpenWhisk helm chart. This OpenWhisk instance should be set to use an external couchdb database and to initialize it. 

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
- `openwhisk.db.wipeAndInit`: This field specifies if the CouchDB instance will be initialized from zero. In this case, the field should be set to *true*.
- `openwhisk.db.host`: This field specifies the hostname of the CouchDB instance used by OpenWhisk. This field should be compliant with the one specified in the CouchDB values. **In particular, in the centralized instance, the host name should be EQUAL to the ClusterIP service name, since the database is deployed inside the cluster**.
- `openwhisk.db.auth.username`: This field specifies the username used to authenticate with CouchDB. **This field should be compliant with the one specified in the CouchDB values.**
- `openwhisk.db.auth.password`: This field specifies the password used to authenticate with CouchDB. **This field should be compliant with the one specified in the CouchDB values.**
- `openwhisk.db.port`: This field specifies the port number used by the CouchDB instance. This field should be compliant with the one specified in the CouchDB values. **In particular, in the centralized instance, the host name should be EQUAL to the ClusterIP service's port, since the database is deployed inside the cluster**.
- `openwhisk.db.protocol`: This field specifies the protocol used by the CouchDB instance.  **In particular, in the centralized instance, the protocol should be HTTP, since the database is deployed inside the cluster and we don't need a specific security to contact it**.
- `openwhisk.providers.kafka.enabled`: This field specifies if the kafka provider is enabled, and should be  set to *false*.


- `couchdb.adminUsername`: This field specifies the username of the CouchDB administrator.
- `couchdb.adminPassword`: This field specifies the password of the CouchDB administrator.
- `couchdb.service.externalPort`: This field specifies the external port number used by the CouchDB service.
- `couchdb.iroute.gateway`: This field specifies the gateway used to route requests to the CouchDB instance.
- `couchdb.couchdbConfig.couchdb.uuid`: This field specifies the UUID of the CouchDB instance.

- `grafana.auth.admin.username`: This field specifies the username of the Grafana administrator.
- `grafana.auth.admin.password`: This field specifies the password of the Grafana administrator.
- `grafana.influx.token`: This field specifies the authentication token used to connect to InfluxDB. **It must be equal to the token specified in InfluxDB values.**
- `grafana.influx.organization`: This field specifies the organization used by InfluxDB. **It must be equal to the organization specified in InfluxDB values.**
- `grafana.influx.bucket`: This field specifies the bucket used by InfluxDB. **It must be equal to the bucket specified in InfluxDB values.**
- `grafana.influx.url`: This field specifies the URL of the InfluxDB instance. **The url must be composed in this way: "http://<influxdb-clusterIp-service-name>:<InfluxDBClusterIPPort>"**
- `grafana.global.domain_name`: This field specifies the domain name used by Grafana. **It should be equal to the cluster domain name**

- `influxdb2.adminUser.user`: This field specifies the username of the InfluxDB administrator.
- `influxdb2.adminUser.password`: This field specifies the password of the InfluxDB administrator.
- `influxdb2.adminUser.token`: This field specifies the authentication token used to connect to InfluxDB.
- `influxdb2.adminUser.organization`: This field specifies the organization used by InfluxDB.
- `influxdb2.adminUser.bucket`: This field specifies the bucket used by InfluxDB.
- `influxdb2.iroute.externalUrl`: This field specifies the external URL used by InfluxDB.

- `.mqtt-provider.provider.providerPort`: sets the port number that the MQTT provider listens on.
- `.mqtt-provider.provider.couchdbUsername`: sets the username for the CouchDB instance used by MQTT provider. **It should be consistent with the CouchDB username provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbPassword`: sets the password for the CouchDB instance used by MQTT provider. **It should be consistent with the CouchDB password provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbGateway` : sets the gateway address for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `.mqtt-provider.provider.couchdbExtPort`: sets the external port number for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the port should be 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `.mqtt-provider.openwhisk.apiHost`: sets the API host for OpenWhisk, which is used by MQTT provider. **It should be consistent with the local OpenWhisk API Host, which is set in the values file**.


It is important to enable persistence for both InfluxDB and CouchDB.