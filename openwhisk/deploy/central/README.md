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
2. [Bash Script deploy.sh](#bash-script-deploy.sh)
3. [Bash Script addAggregateAction.sh](#bash-script-addAggregateAction.sh)
4. [Values File and Deployed Services](#values-file-and-deployed-services)
5. [Actions and Triggers](#actions-and-triggers)
6. [Action's Parameters](#action's-parameters)

## Introduction

This folder contains some files to develop the centralized solution based on Openwhisk.

You will find two files and a folder:
1. [deploy.sh]: the script to be executed to deploy the central solution.
2. [values.yaml]: the value file used to deploy the helm chart related to the central solution.
3. [openwhisk]: a folder containing a views.json file and the OpenWhisk actions
4. [addAggregateAction.sh]: a script to add a new aggregate action.



## Bash Script Depoly.sh

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
6. After having correctly deployed openwhisk, it will initialize the CouchDB database in order to provide the tables needed by the MQTT provider that will be deployed in the edge instances.
7. After having correctly deployed openwhisk, it checks if the OpenWhisk actions, triggers and rules have already been created and, if they are not found, it creates them. 
8. It creates an external user to access the Grafana Dashboard.

## Bash Script addAggregateAction.sh

To add an aggregate action, we must run the following command:
To deploy the central solution, we must run the following command inside this folder:

```
./addAggregateAction.sh <actionName> <ruleName> <actionFileName>
```

The action file should be placed inside the following [folder](./openwhisk/actions-and-triggers/aggregates/).

## Values File and Deployed Services

The deployed chart is composed by multiple subcharts, it particular it includes:

1. OpenWhisk and all its related services
2. The CouchDB database used by the local and remote OpenWhisk instances
3. The InfluxDB database, used to store aggregate data
4. Grafana Operator
5. Grafana 
6. MQTT provider, to add, modify and delete triggers that are listening on MQTT topics.

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

- `.mqtt-provider.provider.providerPort`:  the port number that the Mosquitto provider listens on.
- `.mqtt-provider.provider.couchdbUsername`: the username for the CouchDB instance used by Mosquitto. **It is should be consistent with the CouchDB username provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbPassword`: sets the password for the CouchDB instance used by Mosquitto. **It is consistent with the CouchDB password provided in the centralized instance.**
- `.mqtt-provider.provider.couchdbGateway` : sets the gateway address for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `.mqtt-provider.provider.couchdbExtPort`: sets the external port number for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the port is 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `.mqtt-provider.openwhisk.apiHost`: sets the API host for OpenWhisk, which is used by Mosquitto. **It is consistent with the local OpenWhisk API Host, which is set in the values file**.

Persistence is enabled for both InfluxDB and CouchDB.

## Actions and Triggers 

As we said, the final part of the script creates the triggers, actions ecc...

In our use case, we use an MQTT trigger (taken from [here](https://blog.zhaw.ch/splab/2019/03/15/building-a-sample-mqtt-based-application-on-openwhisk/)) to listen to the MQTT broker for new data, and when new data is published, the trigger fires and invokes an OpenWhisk action.

The MQTT trigger is created using the MQTT package, which provides an easy way to listen to an MQTT broker. The trigger is configured to listen to a specific MQTT topic and to fire when new data is published on that topic. When the trigger fires, it sends a message to the OpenWhisk platform, which then invokes the associated action *addReadingToDb*.

The OpenWhisk action is the code that gets executed when the trigger is fired. In our use case, the action is responsible for writing the new data to a local InfluxDB instance. The action is written in JavaScript and is deployed as a Docker container. OpenWhisk automatically scales the number of containers based on the incoming workload, making it easy to handle increased load without requiring additional infrastructure or configuration.

When the trigger fires, the OpenWhisk platform decides in which invoker to create a new container for the action. The invoker is a node in the cluster that is available to run the container. Once the container is created, it runs the code of the action, writes the data to the InfluxDB instance, and then terminates.

In addition to the trigger that we previously discussed, there is another trigger in our OpenWhisk system that uses the alarm package. This trigger fires an action every 30 minutes to compute aggregates of data stored in the database.

The alarm package is a native OpenWhisk package that provides a simple way to schedule periodic invocations of an action. It uses a cron-like syntax to specify the timing of the invocation, and can be used to trigger actions at regular intervals.

In our case, we are using the cron parameter of the alarm package to specify that the action should be triggered every 30 minutes. The action that is triggered by this package computes aggregates of data stored in the database, such as average temperature readings or total energy usage.

The action that is triggered by this package is implemented using JavaScript and the Node.js runtime. It connects to the local InfluxDB, retrieves the necessary data, and performs the required computations to generate the aggregates. Once the computation is complete, the action can store the results in the centralized InfluxDB instance.

The name of the action that is triggered by the alarm package is aggregatesAction. This action is registered in our OpenWhisk system and can be invoked manually if necessary. However, the primary purpose of this action is to be triggered automatically by the alarm package every 30 minutes to keep our aggregated data up to date.

The trigger and action mechanism in OpenWhisk provides a highly scalable and cost-efficient way to handle the incoming data from multiple sensors. With this approach, we can easily handle an increased workload without having to manage additional infrastructure or configuration, making it ideal for our use case in a Fog Computing environment.

## Action's Parameters

The script associates some parameters to the actions. 

The actions/triggers/packages are created only ONCE, even if we are going to deploy multiple edge instances. This meanse they will share the same parameters for all the instances, so to ensure that **ALL EDGE INSTANCES ARE PROPERLY WORKING**, they must all be deployed using the same [parameters.yml](./../parameters/parameters.yml).

The next section will explain them and will also explain which value they must have to ensure that the edge instance properly works.

**mqtt package**:
- *provider-endpoint*: this parameter must have the following format  *"http://<mqtt-provider-ClusterIp-serviceName>:<mqtt-provider-ClusterIp-servicePort>/mqtt"*. 

**feed_trigger**:
- *topic*: in this case, the topic is set to *test*. 
- *url*: the url of the local Mosquitto. The paramater must have the following format *"http://<mosquittoUsername>:<mosquittoPassword>@<mosquittoClusterIpServiceName>:$<mosquittoClusterIpServicePort>"*

**addReadingToDb**:
- **influx_url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<influxDBClusterIPServiceName>:<influxDBClusterIpServicePort>"
- **influx_token**: the token of the local influxdb instance.
- **influx_org**: the organization of the local influxDB instance.
- **influx_bucket**: the bucket of the local InfluxDB instance.


**aggregatesTrigger**:
- **cron**: the trigger is fired using the OpenWhisk native Alarm package, which gives us the possibility to schedule when a trigger is fired. In our case, the trigger is fired every 30 minutes.
- **local_url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<localInfluxDBClusterIPServiceName>:<localInfluxDBClusterIpServicePort>"
- **local_token**: the token of the local influxdb instance.
- **local_org**: the organization of the local influxDB instance.
- **local_bucket**: the bucket of the local InfluxDB instance.
- **central_url**: the url to contact the centralized InfluxDB. The parameter must have te following format: "https://<influxDbIngressRouteName>"
- **central_token**: the token of the centralized influxdb instance.
- **central_org**: the organization of the centralized influxDB instance.
- **local_bucket**: the bucket of the centralized InfluxDB instance.