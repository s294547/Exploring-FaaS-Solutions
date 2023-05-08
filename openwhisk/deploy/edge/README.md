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
4. [Actions and Triggers](#actions-and-triggers)
4. [Action's Parameters](#action's-parameters)

## Introduction

This folder contains some files to develop the edge solution based on Openwhisk.

You will find two files and two folders:
1. [deploy.sh]: the script to be executed to deploy the edge solution.
2. [values.yaml]: the value file used to deploy the helm chart related to the edge solution.
3. [openwhisk]: the folder containing the code of OpenWhisk actions.
4. [sensors]: the folder containing the code to configure and allow the sensors to send data to the MQTT provider.


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
5. It sets the parameters to correctly use the wsk cli.
6. After having correctly deployed openwhisk, it checks if the OpenWhisk actions, triggers and rules have already been created and, if they are not found, it creates them. 


## Values File and Deployed Services

The deployed chart is composed by multiple subcharts, it particular it includes:

1. OpenWhisk and all its related services
2. The InfluxDB database, used to store local data sent by sensors
4. Mosquitto + MQTT Provider

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
- `.mosquitto.provider.providerPort`:  the port number that the Mosquitto provider listens on.
- `.mosquitto.provider.couchdbUsername`: the username for the CouchDB instance used by Mosquitto. **It is should be consistent with the CouchDB username provided in the centralized instance.**
- `.mosquitto.provider.couchdbPassword`: sets the password for the CouchDB instance used by Mosquitto. **It is consistent with the CouchDB password provided in the centralized instance.**
- `.mosquitto.provider.couchdbGateway` : sets the gateway address for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the host name of the CouchDB Traefik Ingress Route, since the database is deployed outside the cluster**.
- `.mosquitto.provider.couchdbExtPort`: sets the external port number for the CouchDB instance used by Mosquitto. **In particular, in the edge instance, the port is 443, since the database is deployed outside the cluster and we are going to contact it with HTTPS**.
- `.mosquitto.openwhisk.apiHost`: sets the API host for OpenWhisk, which is used by Mosquitto. **It is consistent with the local OpenWhisk API Host, which is set in the values file**.

Persistence is enabled for both InfluxDB and Mosquitto in the values file.

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

**aggregatesAction**:
- **local_url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<localInfluxDBClusterIPServiceName>:<localInfluxDBClusterIpServicePort>"
- **local_token**: the token of the local influxdb instance.
- **local_org**: the organization of the local influxDB instance.
- **local_bucket**: the bucket of the local InfluxDB instance.
- **central_url**: the url to contact the centralized InfluxDB. The parameter must have te following format: "https://<influxDbIngressRouteName>"
- **central_token**: the token of the centralized influxdb instance.
- **central_org**: the organization of the centralized influxDB instance.
- **local_bucket**: the bucket of the centralized InfluxDB instance.

**aggregatesTrigger**:
- **cron**: the trigger is fired using the OpenWhisk native Alarm package, which gives us the possibility to schedule when a trigger is fired. In our case, the trigger is fired every 30 minutes.







