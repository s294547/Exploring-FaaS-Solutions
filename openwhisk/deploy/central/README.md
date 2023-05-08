# OPENWHISK -  CENTRAL DEPLOYMENT

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

This folder contains some files to develop the centralized solution based on Openwhisk.

You will find two files and a folder:
1. [deploy.sh]: the script to be executed to deploy the central solution.
2. [values.yaml]: the value file used to deploy the helm chart related to the central solution.
3. [openwhisk]: a folder containing a views.json file



## Bash Script

To deploy the central solution, we must run the following command inside this folder:

```
./deploy.sh <namespace-name>
```

The script does several things: 

1. It sets the parameters in the [values.yaml](./values.yaml) file, exploting the parameters of the [parameters.yml](./../parameters/parameters.yml) file and additional cluster information.
2. It creates the provided namespace
3. It adds the chartmuseum repository for helm charts
4. It deploys the helm chart relative to the central solution, using the [values.yaml](./values.yaml) file.
5. It sets the parameters to correctly use the wsk cli
6. After having correctly deployed openwhisk, it will initialize the CouchDB database in order to provide the tables needed by the MQTT provider that will be deployed in the edge instances.ù
7. It creates an external user to access the Grafana Dashboard.

## Values File and Deployed Services

The deployed chart is composed by multiple subcharts, it particular it includes:

1. OpenWhisk and all its related services
2. The CouchDB database used by the local and remote OpenWhisk instances
3. The InfluxDB database, used to store aggregate data
4. Grafana Operator
5. Grafana 

The chart is retrieved from the chartmuseum helm repository and its subcharts are also stored in that.

The [values.yaml](./values.yaml) file has different sections, which are obviously related to the different subcharts.

**SOME VALUES ARE ALREADY SET IN THE VALUES FILE AND ARE NOT GOING TO BE TOUCHED BY THE SCRIPT, WHILE OTHER VALUES ARE GOING TO BE MODIFIED ACCORDING TO WHAT IS PROVIDED IN THE FILE [PARAMATERS.YML](./../parameters/parameters.yml)**

The following section will explain the critical values that can be found in [values.yaml](./values.yaml) and what they are going to contain.

The fields are:

- `openwhisk.auth.guest`: This field specifies the guest authentication key for OpenWhisk.
- `openwhisk.whisk.ingress.apiHostName`: This field contains the Cluster's Master Node IP.
- `openwhisk.whisk.ingress.apiHostName`: This field contains the Node Port on which the OpenWhisk API Host will be exposed.
- `openwhisk.db.external`: This field specifies if the CouchDB has already been created or not. It is set to *true*.
- `openwhisk.db.wipeAndInit`: This field specifies if the CouchDB instance will be initialized from zero. In this case, the field is set to *true*.
- `openwhisk.db.host`: This field specifies the hostname of the CouchDB instance used by OpenWhisk. This field is compliant with the one specified in the CouchDB values. **In particular, in the centralized instance, the host name is EQUAL to the ClusterIP service name, since the database is deployed inside the cluster**.
- `openwhisk.db.auth.username`: This field specifies the username used to authenticate with CouchDB. **This field is compliant with the one specified in the CouchDB values.**
- `openwhisk.db.auth.password`: This field specifies the password used to authenticate with CouchDB. **This field is compliant with the one specified in the CouchDB values.**
- `openwhisk.db.port`: This field specifies the port number used by the CouchDB instance. This field is compliant with the one specified in the CouchDB values. **In particular, in the centralized instance, the port is EQUAL to the ClusterIP service's port, since the database is deployed inside the cluster**.
- `openwhisk.db.protocol`: This field specifies the protocol used by the CouchDB instance.  **In particular, in the centralized instance, the protocol is HTTP, since the database is deployed inside the cluster and we don't need a specific security to contact it**.
- `openwhisk.providers.kafka.enabled`: This field specifies if the kafka provider is enabled, and is set to *false*.


- `couchdb.adminUsername`: This field specifies the username of the CouchDB administrator.
- `couchdb.adminPassword`: This field specifies the password of the CouchDB administrator.
- `couchdb.service.externalPort`: This field specifies the external port number used by the CouchDB service.
- `couchdb.iroute.gateway`: This field specifies the gateway used to route requests to the CouchDB instance.
- `couchdb.couchdbConfig.couchdb.uuid`: This field specifies the UUID of the CouchDB instance.

- `grafana.auth.admin.username`: This field specifies the username of the Grafana administrator.
- `grafana.auth.admin.password`: This field specifies the password of the Grafana administrator.
- `grafana.influx.token`: This field specifies the authentication token used to connect to InfluxDB. **It is equal to the token specified in InfluxDB values.**
- `grafana.influx.organization`: This field specifies the organization used by InfluxDB. **It is equal to the organization specified in InfluxDB values.**
- `grafana.influx.bucket`: This field specifies the bucket used by InfluxDB. **It is equal to the bucket specified in InfluxDB values.**
- `grafana.influx.url`: This field specifies the URL of the InfluxDB instance. **The url is composed in this way: "http://<influxdb-clusterIp-service-name>:<InfluxDBClusterIPPort>"**
- `grafana.global.domain_name`: This field specifies the domain name used by Grafana. **It is equal to the cluster's domain name**

- `influxdb2.adminUser.user`: This field specifies the username of the InfluxDB administrator.
- `influxdb2.adminUser.password`: This field specifies the password of the InfluxDB administrator.
- `influxdb2.adminUser.token`: This field specifies the authentication token used to connect to InfluxDB.
- `influxdb2.adminUser.organization`: This field specifies the organization used by InfluxDB.
- `influxdb2.adminUser.bucket`: This field specifies the bucket used by InfluxDB.
- `influxdb2.iroute.externalUrl`: This field specifies the external URL used by InfluxDB.

Persistence is enabled for both InfluxDB and CouchDB.
