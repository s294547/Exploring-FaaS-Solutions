# Deploying multiple Openwhisk Instances

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Deploying Openwhisk](#deploying-openwhisk)
3. [Deploying Mosquitto](#deploying-mosquitto)
4. [Deploying InfluxDB](#deploying-influxdb)
5. [Deploying MQTT Provider and Trigger](#deploying-mqtt-provider-and-trigger)
	1. [Deploying the Slim MQTT Provider](#deploying-the-slim-mqtt-provider)
	2. [Deploying the trigger and action](#deploying-the-trigger-and-action)
6. [Deploying the action and trigger to compute aggregates](#deploying-the-action-and-trigger-to-compute-aggregates)
7. [Considerations and decision to change approach](#considerations-and-decision-to-change-approach)
	1. [Deploying InfluxDB](#deploying-influxdb-1)
	2. [Deploying Mosquitto](#deploying-mosquitto-1)
	3. [Deploying the trigger and action](#deploying-the-trigger-and-action-1)
	4. [Deploying the aggregates action and trigger](#deploying-the-aggregates-action-and-trigger)

## Introduction

In this file I am briefly going to summarize how I deployed multiple Openwhisk instances to test how they work with each other and if it creates problems.

## Deploying OpenWhisk

To deployed another Openwhisk instance, I followed the instructions in [this file](./../README.md). This time, I used the namespace *openwhisk-second-instance*. I also had to change in the right way the file *mycluster.yaml* so that the CouchDB instance is not initialized again.

## Deploying Mosquitto

Since ideally this new Openwhisk instance should be on another local data center, we'll need to follow the steps provided in [this file](./../mosquitto/README.md) to deploy another mosquitto broker. We'll create it in the namespace *mosquitto-second-instance*.

## Deploying InfluxDB

This new instance requires also its local database, so we will deploy another instance of InfluxDB as specified in [this file](./../influxdb/REAMDE.md) in the namespace *influxdb-second-instance*.

## Deploying MQTT Provider and Trigger

In our Fog Computing environment, we have multiple data centers, each with sensors that publish data to an MQTT broker. To process this data and save it in a local InfluxDB, we decided to use OpenWhisk instances deployed in each data center, but we faced a challenge on how to replicate resources between namespaces.

Initially, we tried recreating everything for each local OpenWhisk deployment in different namespaces to avoid different users in different data centers from touching other things. However, this solution wasn't ideal as it meant we had to recreate everything, which would have been a significant overhead and would have reduced the power of OpenWhisk.

We then explored an alternative approach, which involved re-creating the trigger, package, and feed, but not the action. However, to do this, all the OpenWhisk instances had to work in the same namespace, which would have lost the protection between different namespaces.

After considering these options, we decided to develop our own "slim" MQTT provider, which would be used across all namespaces. This approach involved creating only one trigger and one action for all namespaces, which reduced the replication of resources. We also eliminated the need for packages, feeds, and other OpenWhisk constructs that were not necessary for our use case. Instead, we used environment variables to configure our slim MQTT provider, which simplified the deployment process and reduced the chances of errors.

With this approach, we could also maintain the isolation between different namespaces. Using a centralized CouchDB ensured that all data was stored in a single location, making it easier to manage and analyze. Our slim MQTT provider also helped us avoid creating duplicates of actions in different namespaces, reducing the chances of conflicts and errors.

Overall, we believe that developing our slim MQTT provider was the best solution for our Fog Computing environment. It simplified the deployment process, reduced replication of resources, and maintained the isolation between different namespaces. 

### Deploying the Slim MQTT Provider

In [this folder](./../mosquitto/openwhisk_mqtt_feed/provider-slim) we can find the all the files used to create the new solution. 

To create a deployment with our slim mqtt provider, we first need to build and push the new docker image.

```
sudo docker build  -f Dockerfile -t mqtt_service_provider_slim:latest .
docker tag mqtt_service_provider_slim:latest giuliabianchi1408/mqtt_service_provider_slim:latest
docker push giuliabianchi1408/mqtt_service_provider_slim:latest
```

After that, to use the important parameters as environment variables in the mqtt provider, we need to set with the opportune values this [ConfigMap](./../mosquitto/openwhisk_mqtt_feed/provider-slim/configmap.yml). There is no need to add parameters, but to modify in the right way the parameters already present.

```
kubectl apply -f confimap.yml -n mosquitto-second-instance
```

Now we are ready to deploy the slim mqtt provider, enhanced with the environment parameters.

```
kubectl apply -f confimap.yml -n mosquitto-second-instance
```

### Deploying the trigger and action

At this point, it is necessary to create the trigger, action and rule. This needs to be done only **ONCE** for all the data centers, since they will use the same trigger/action/rule.

```
wsk action create addReadingToDb addReadingsToDB.js
wsk trigger create addReadingToDbTrigger
wsk rule create addReadingToDbRule addReadingToDbTrigger addReadingToDb
```
## Deploying the action and trigger to compute aggregates

To compute aggregates, I am going to re-use the already deployed action *aggregatesAction*, which has been deployed acccording to [this file](./../mosquitto/compute_daily_aggregates/README.md). I also want to re-use the same trigger, action and rule, but each action in each data center should use different parameters. To do that, i will use the command *wsk action update*, which updates the code and parameters for a specific action in the OpenWhisk instance that you are currently targeting. Other instances of OpenWhisk, even if they are running on the same Kubernetes cluster, will not be affected by this update. Each instance has its own environment and set of parameters, so you can update the action parameters independently in each instance. 

If you update the code of an action, the change will be reflected in all the instances of OpenWhisk that have access to the action. However, if you update the parameters of the action, the changes will only affect the instance of OpenWhisk where the update was performed.

If you have an OpenWhisk action in two instances that share the same CouchDB database, and you update the code and parameters of the action in one instance, then when the cache for the other instance expires or is invalidated, the instance will retrieve the updated code from the database, but it will still have the old parameters.

This is because each instance maintains its own local state for each action, including the parameters, and the state is not automatically synchronized between instances. Therefore, if you want the parameters to be consistent across all instances, you should update them separately in each instance after updating the code.

So, we have to create the action first using [this file](./../mosquitto/compute_daily_aggregates/aggregatesAction.js). 

```

```

We also have to create the trigger and the rule:

```
wsk trigger create aggregatesTrigger --feed /whisk.system/alarms/alarm --param cron "0 3 * * *"
wsk rule create aggregatesRule aggregatesTrigger aggregatesAction
```

These steps must be done only *ONCE* for all the instances. Then, for each, instance, we must update the action with the correct parameters, for example:

```
wsk action update aggregatesAction --param-file parameters.json
```

Trying that, i sadly discovered that this wasn't true.

So, we are at the same point we were with the MQTT provider. Since we already have the MQTT provider which is constantly running, we could use it also to fire the trigger at the desired time. 

So, I've decided to modify the code of the *mqtt-provider-slim* adding this functionality. To do that, I must follow all the previous steps to re-deploy it again. I created a new mqtt provider, which is called [provider_slim_and_alarm](./../mosquitto/openwhisk_mqtt_feed/provider-slim-and-alarm/).  To do that, i created a new docker image, updated the deployment with the new docker image and updated the confgimaps with the new parameters, this has to be done for all the data center instances. After that, i created the trigger *aggregatesTrigger*, the action *aggregatesAction* and the rule *aggregatesRule*, just once for all the openwhisk deployments.

## Considerations and decision to change approach

In this way, if there is the necessity to change somehow the parameters, this will have to be done FOR EACH CLIENT. We clearly don't like this architecture, since we'd like each modification to be handled in a centralized way: modifying all clients requires a greater effort than modifying just the "server". 

For this reason, I've used the same parameters for all the deployments. To do that, for example, I'll access different service just using their name and their port, but to do that I need to have the same name of service inside different namespaces. To do that, I'll need to move all the components (influxdb, openwhisk, mosquitto) just inside one namespace. This is important not only because it is helping us to have fixed parameters, but also because in enterprise context, the namespace becomes a degree of separation for an application stack, rather than for a single technology.

### Deploying InfluxDB

In our scenario, we have two namespaces for two different deployments: *openwhisk* and *openwhisk-second-instance*.

We'll move influxdb and mosquitto inside them. In this case, I will just remove them and deploy them again.

```
kubectl delete namespace influxdb
kubectl delete namespace influxdb-second-instance
```

Then, we'll need to deploy again influxdb. We'll need to use a fixed value for the auth token, for the central organization and for the bucket.

```
helm upgrade --install influxdb  influxdata/influxdb2 -n openwhisk -f /mnt/c/Users/yukik/exploring-faas/openwhisk/influxdb/values.yml

helm upgrade --install influxdb  influxdata/influxdb2 -n openwhisk-second-instance -f /mnt/c/Users/yukik/exploring-faas/openwhisk/influxdb/values.yml
```

Here's the important part of the file [values.yaml](./../influxdb/values.yml) that has been modified to get constant parameters in each deployment:

```
  organization: "influxdata"
  bucket: "measure"
  user: "admin"
  retention_policy: "0s"
  ## Leave empty to generate a random password and token.
  ## Or fill any of these values to use fixed values.
  password: "adminopenwhiskinfluxdb"
  token: "ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ"
```

There is no need to install the ingress, we'll need to install it just for the centralized influxdb instance. Anyway, I will deploy them to have access to the DBs to see if they have the required data.

### Deploying Mosquitto

We'll need to follow the steps provided in [this file](./../mosquitto/README.md) to deploy another mosquitto broker in the *openwhisk* and *openwhisk-second-instance* namespace. 

But, at first, I needed to delete the previously deployed instances:

```
kubectl delete namespace mosquitto
kubectl delete namespace mosquitto-second-instance
```

TBN: since when deploying openwhisk the helm chart creates a network policy that allows incoming traffic in the openwhisk namespace only for certain services, I had to modify the netpol *openwhisk-frontend-np* to accept the incoming traffic form pods with the label *name* equal to mosquitto. 

I have also updated the file in the helm chart so that this netpol will be created automatically in the updated version when deploying the helm again. (We can find the template [here](./../../openwhisk-deploy-kube/helm/openwhisk/templates/network-policy.yaml)).

### Deploying the trigger and action

I want to handle the possibility in which each local instance wants to start monitoring new MQTT topics. To do that, we'll go back to the trigger implementation that exploits the usage of packages and feed actions.

At first, we'll need to delete the previosuly defined rule, trigger and action.

```
wsk rule delete addReadingToDbRule -i
wsk action delete addReadingToDb -i
wsk trigger delete addReadingToDbTrigger -i
```

We'll be back using [this MQTT provider](./../mosquitto/openwhisk_mqtt_feed/provider/). We'll need to follow the steps required to deploy this solution according to the constant parameters across the differents OpenWhisk deployments.

We first need to create inside each distinct deployment the MQTT provider:

``` 
kubectl apply -f deployment.yaml -n openwhisk
kubectl apply -f deployment.yaml -n openwhisk-second-instance
``` 
Where *deployment.yaml* is [this](./../mosquitto/openwhisk_mqtt_feed/deployment.yaml) file.

Then we need to expose them:

``` 
kubectl expose deployment mqtt-provider --port='3000' --type='ClusterIP' -n openwhisk 
kubectl expose deployment mqtt-provider --port='3000' --type='ClusterIP' -n openwhisk-second-instance
``` 
After that, we must run the following commands:

``` 
wsk package create --shared yes -p provider_endpoint "http://mqtt-provider:3000/mqtt" mqtt
``` 
``` 
wsk package update mqtt -a description 'The mqtt package provides functionality to connect to MQTT brokers'
``` 
```
wsk action create -a feed true mqtt/mqtt_feed feed_action.js
```
```
wsk trigger create /guest/feed_trigger --feed /guest/mqtt/mqtt_feed -p topic 'test' -p url "http://test:test@mosquitto:1883" -p triggerName '/guest/feed_trigger'
```

In this case, it was also needed to modify the netpol, so I did that.

```
$ wsk action create addReadingToDb addReadingsToDB.js --param influx_url "http://influxdb-influxdb2:80" --param influx_token "ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ" --param influx_org "influxdata" --param influx_bucket "measure"
$ wsk rule create mqttRule '/guest/feed_trigger' addReadingToDb

```

While the MQTT provider must be deployed for each openwhisk instance, these steps must be done just once for the entire fog computing architecture.

### Deploying the aggregates action and trigger 

I needed to delete the *influxdb-centralized* namespace and deploy the *influxdb-centralized* instance again to have a central database with standard parameters. To achieve this, this time, i used [this *values.yaml*](./../influxdb/values-centralized.yml). 

We will create a trigger that is fired at 3:00 every day and computes some aggregates. Then, the aggregates are all sent to a remote DB, and they will be stored according to the name of the data center which they were computed. 



```
wsk action update aggregatesAction aggregatesAction.js --param local_url "http://influxdb-influxdb2:80" --param local_token "ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ" --param local_org "influxdata" --param local_bucket "measure" --param central_url "https://influxdb-centralized-gateway.liquidfaas.cloud" --param central_token "ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ" --param central_org "influxdata" --param central_bucket "aggregates" -i
wsk trigger create aggregatesTrigger --feed /whisk.system/alarms/alarm --param cron "0 3 * * *" 

```

Then, I must bind the trigger to the action:

```
wsk rule create aggregatesRule aggregatesTrigger aggregatesAction -i
``` 

Those actions need to be done just once for all the openwhisk deployments.


