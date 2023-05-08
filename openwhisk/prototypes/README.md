# OPENWHISK - PROTOTYPES OF THE PROJECT

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Required Tools Installation](#required-tools-installation)
	1. [Helm](#helm)
	2. [OpenWhisk CLI](#openwhisk-cli)
	3. [Git openwhisk-deploy-kube repo](#git-openwhisk-deploy-kube-repo)
3. [Deploy OpenWhisk](#deploy-openwhisk)
	1. [Set up a mycluster.yaml file](#set-up-a-mycluster.yaml-file)
	2. [Create a namespace](#create-a-namespace)
	3. [Indicate usable nodes](#indicate-usable-nodes)
    4. [Deploy OpenWhisk with Helm](#deploy-openwhisk-with-helm)
4. [Configure the wsk cli properties](#configure-the-wsk-cli-properties)
5. [Create an action](#create-an-action)
	1. [What happens in OpenWhisk components](#what-happens-in-openwhisk-components)
6. [Invoke an action](#invoke-an-action)
	1. [What happens in OpenWhisk components](#what-happens-in-openwhisk-components-1)
7. [Delete an action](#delete-an-action)
	1. [What happens in OpenWhisk components](#what-happens-in-openwhisk-components-2)
8. [Remove OpenWhisk](#remove-openwhisk)
9. [OpenWhisk Deep Dive](#openwhisk-deep-dive)
	1. [Jobs](#jobs)
	2. [Deployments](#deployments)
	3. [Stateful Sets](#statefulsets)
	4. [Pods](#pods)
10. [Additional Informations](#additional-informations)
	1. [Openwhisk datastore cache](#openwhisk-datastore-cache)
	1. [ShardingContainerPoolBalancer](#shardingcontainerpoolbalancer)

## Introduction

This file will document all the steps required to deploy OpenWhisk on a given Kubernetes Cluster.
This example was done using Docker Desktop on Windows 11 with Ubuntu 22 WSL 2. 
It will also be reported an example of how to create an action in OpenWhisk. 

Considering this folder, it contains all the informations related to how our openwhisk instance has been deployed and what components I needed to add progressively to develop my thesis. **THIS FOLDER CONTAINS ALL THE FILES, INFORMATIONS AND RESOURCES USED WHILE DEVELOPING THE THESIS WORK, SO THERE MAY BE SOME WRONG  OR NON-DEFINITIVE DATA. THE FINAL VERSION OF THE CENTRALIZED AND EDGE DEPLOYMENTS ARE IN [THIS FOLDER](./../deploy/)**

In particular, we can see other folders inside this one:
1. [cert](./cert/): it contains openwhisk certificates.
2. [cli](./cli/): it contains the openwhisk cli.
3. [traefik-master](./traefik-master/): it contains the helm chart to deploy traefik on my cluster.
4. [openwhisk-deploy-kube](./openwhisk-deploy-kube/): it contains the helm chart to deploy openwhisk, opportunely modified for our use case.
5. [IoT protocols](./IoT%20protocols/): it contains the process followed to decide how to implement the trigger that is fired when data are published on an MQTT topic.
6. [influxdb](./influxdb/): it contain the informations about how to deploy an influxdb instance.
7. [mosquitto]: it contains all the informations and data related to the MQTT broker deployed inside each cluster and  the trigger which is fired when data are published on an MQTT topic.
8. [fixing-nodejsaction](./fixing-nodejsaction/): it contains the information regarding how the runtime for nodejs has been fixed in this openwhisk instance.
9. [couchdb-external](./couchdb-external/): it contains the informations and the data to deploy an external couchdb instance in our openwhisk instance, which is shared between the different openwhisk local instances.
10. [compute_daily_aggregates](./compute_daily_aggregates/): it contains the informations and data used to develop an openwhisk action that is fired periodically, it computes some local aggregates and sends them to a centralized InfluxDB instance.
11. [deploy-multiple-instances](./deploy-multiple-instances/): it contains all the informations, decisions and the whole process followed to adapt all the experimented tools in a multiple-instance design. I've first experimented the solution on a single openwhisk instance to see if it was working, then I extended it in a multiple-instance design, exploiting different kubernetes namespaces. 
12. [arduino-project](./arduino-project/): it contains the arduino project developed by me that works on an ESP-8266 provided with  humidity, temperature and gas sensors and publish a message to a given MQTT broker.   
13. [chartmuseum](./chartmuseum/): it contains the helm chart to deploy a helm repository.
14. [grafana](./grafana/): it contains the helm charts to deploy grafana and grafana operator. There are also some informations about how the dashoards have been organized in our use case.


## Required Tools Installation
### Helm
We will use Helm to deploy OpenWhisk on Kubernetes so let’s install it.

```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
### OpenWhisk CLI
Install the wsk cli.

```
curl -L -O https://github.com/apache/openwhisk-cli/releases/download/1.1.0/OpenWhisk_CLI-1.1.0-linux-amd64.tgz
mkdir wsk-cli
tar -xvzf OpenWhisk_CLI-1.1.0-linux-amd64.tgz -C wsk-cli
sudo ln -s $HOME/wsk-cli/wsk /usr/local/bin/wsk
```

### Git openwhisk-deploy-kube repo
Clone the Git openwhisk-deploy-kube repo.

```
git clone https://github.com/apache/openwhisk-deploy-kube.git
cd openwhisk-deploy-kube
```

## Deploy OpenWhisk

### Set up a *mycluster.yaml* file

Check what InternalIP we have and port 31001 is available.


```
kubectl describe nodes | grep "InternalIP"
sudo netstat -tulpn | grep 31001
```
Create a mycluster.yaml file. The apiHostName field should be set with the InternalIP value.

```
whisk:
  ingress:
    type: NodePort
    apiHostName: 192.168.65.3
    apiHostPort: 31001
 
nginx:
  httpsNodePort: 31001
```

### Create a namespace
Create a Kubernetes namespace for OpenWhisk.

```
kubectl create namespace openwhisk
```

### Indicate usable nodes 

Indicate that all nodes can be used by OpenWhisk to execute containers.

```
kubectl label nodes --all openwhisk-role=invoker
```

### Deploy OpenWhisk with Helm

Deploy OpenWhisk using Helm.

```
helm install owdev ./helm/openwhisk -n openwhisk -f mycluster.yaml
```

Wait for the deployment to be complete by observing the status of the pods created.
The deployment will be finished when the install-packages pod status is completed.

## Configure the wsk cli properties

Configure the wsk cli apihost property. The apihost should be the one indicated in the mycluster.yaml file. If the cluster node is in our local machine, we can use localhost. 

```
wsk -i property set --apihost localhost:31001
```
List users in the guest namespace.

```
kubectl -n openwhisk -ti exec owdev-wskadmin -- wskadmin user list guest
```

And use the string you get to set the wsk cli auth property.

```
wsk -i property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP
```
## Create an Action

Create a JavaScript file, helloWorldAction.js, for a Node.js serverless function.

```
const os = require('os')
 
function main(params) {
    const name = params && params.name || 'anonymous'
    const hostname = os.hostname()
    const message = `Hello ${name} from ${hostname}`
    const body = JSON.stringify({
        name,
        hostname,
        message
    })
    const response = {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body
    }
    return response
}
```
Create a web action.

```
wsk -i action create helloWorldAction helloWorldAction.js --web true
```
### What happens in OpenWhisk components

After creating an action, I checked the logs of the controller pod to better understand what is exactly happening. So, i executed this command:

```
kubectl get logs owdev-controller-0 -n openwhisk

```

Here are reported the logs retrieved, all of them followed by a clear explanation of what is happening. For more informations about the *Openwhisk datastore cache*, read [this section](#openwisk-datastore-cache)

1. 
``` 
[2023-02-24T13:48:26.445Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] PUT /api/v1/namespaces/_/actions/helloWorldAction overwrite=false
```
 This log entry indicates that a PUT request was made to create an OpenWhisk action called "helloWorldAction" with the "overwrite" parameter set to "false", so the write operation will fail if there is already data stored with the same key.
2.
```
[2023-02-24T13:48:26.584Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [Identity] [GET] serving from datastore: CacheKey(23bc46b1-71f6-4ed5-8c54-816aa4f8c502) [marker:database_cacheMiss_counter:146]
```
This entry indicates that a GET request was made to retrieve an identity from the data store cache. Since a marker database_cacheMiss_counter can be seen in the log, we can guess that, the data being requested was not found in the system's cache, and had to be retrieved from the datastore.

3.
```
[2023-02-24T13:48:26.591Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [CouchDbRestStore] [QUERY] 'test_subjects' searching 'subjects.v2.0.0/identities [marker:database_queryView_start:154]
```
This log entry indicates that a query was made to the CouchDB database to search for identities that match the specified criteria. The query was initiated at the marker point 154.

4.
```
[2023-02-24T13:48:26.812Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [CouchDbRestStore] [marker:database_queryView_finish:374:220]
```
This entry indicates that the CouchDB query from the previous log entry has completed. The marker point 374:220 indicates the time elapsed since the start of the query.

5.
```
[2023-02-24T13:48:27.031Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [WhiskAction] [GET] serving from datastore: CacheKey(guest/helloWorldAction) [marker:database_cacheMiss_counter:594]
```
This entry indicates that a GET request was made to retrieve the "helloWorldAction" action from the OpenWhisk datastore cache.Since a marker database_cacheMiss_counter can be seen in the log, we can guess that, the data being requested was not found in the system's cache, and had to be retrieved from the datastore.

6.
```
[2023-02-24T13:48:27.032Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [CouchDbRestStore] [GET] 'test_whisks' finding document: 'id: guest/helloWorldAction' [marker:database_getDocument_start:595]
```
This entry indicates that a GET request was made to retrieve the "helloWorldAction" action document from the CouchDB database. The request was initiated at the marker point 595.

7.
```
[2023-02-24T13:48:27.304Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [WhiskAction] write initiated on new cache entry
```
This log indicates that a write operation has been initiated on a new cache entry.


8.
```
[2023-02-24T13:48:27.366Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [CouchDbRestStore] [PUT] 'test_whisks' saving document: 'id: guest/helloWorldAction, rev: null' [marker:database_saveDocument_start:928]
```
This log entry shows that a PUT request is being made to save a document with an ID of "guest/helloWorldAction" in the "test_whisks" database, with a revision of null.

9.
```
[2023-02-24T13:48:27.419Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [CouchDbRestStore] [marker:database_saveDocument_finish:982:53]
```
This log entry shows that the document save operation has finished with a timestamp of 982ms and 53ms of processing time.

10.
```
[2023-02-24T13:48:27.421Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [WhiskAction] write all done, caching CacheKey(guest/helloWorldAction) Cached
```
This log entry shows that the write operation for the "helloWorldAction" action has been completed, and it has been cached with the key "CacheKey(guest/helloWorldAction)".

11.
```
[2023-02-24T13:48:27.503Z] [INFO] [#tid_V0BhIvDMwJf3EpjW5tDYHbwIiXn7wWCI] [BasicHttpService] [marker:http_put.200_counter:1065:1065]
```
This log entry shows that the HTTP PUT request for the "helloWorldAction" action has been completed successfully with a 200 status code. The counter value of 1065 indicates the number of successful PUT requests that have been processed by the system.
## Invoke an Action
You can now invoke the action from shell.
```
wsk -i action invoke helloWorldAction --result --param name Roberto
```
You will see that OpenWhisk creates automatically containers running your serverless function.

Or get the action URL to use it as a webservice.
```
wsk -i action get helloWorldAction --url
```
You can use the action URL to test it through Postman.

### What happens in OpenWhisk components

#### Controller Logs 

After having invoked an action, I checked the logs of the controller pod to better understand what is exactly happening. So, i executed this command:

```
kubectl get logs owdev-controller-0 -n openwhisk

```

Here are reported the logs retrieved, all of them followed by a clear explanation of what is happening. For more informations about the *Openwhisk datastore cache*, read [this section](#openwisk-datastore-cache), while for more informations about the *ShardingContainerPoolBalancer* read [this section](#shardingcontainerpoolbalancer).

1.
```
[2023-02-24T14:40:40.816Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] POST /api/v1/namespaces/_/actions/helloWorldAction blocking=true&result=true
```
The application receives a POST request to the /api/v1/namespaces/_/actions/helloWorldAction endpoint with blocking=true and result=true parameters.

2.
```
[2023-02-24T14:40:40.892Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [Identity] [GET] serving from datastore CacheKey(23bc46b1-71f6-4ed5-8c54-816aa4f8c502) [marker:database_cacheMiss_counter:15]
```
The application retrieves an identity from the datastore cache. Since a marker database_cacheMiss_counter can be seen in the log, we can guess that, the data being requested was not found in the system's cache, and had to be retrieved from the datastore.

3.
```
[2023-02-24T14:40:40.892Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [QUERY] 'test_subjects' searching 'subjects.v2.0.0/identities [marker:database_queryView_start:15]
```
The application performs a query on the test_subjects CouchDB database to retrieve identities.

4.
```
[2023-02-24T14:40:40.930Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [marker:database_queryView_finish:115:100]
```
The query on the test_subjects CouchDB database finishes successfully.

5.
```
[2023-02-24T14:40:41.339Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [WhiskActionMetaData] [GET] serving from datastore: CacheKey(guest/helloWorldAction) [marker:database_cacheMiss_counter:524]
```
The application retrieves metadata related to the helloWorldAction action from the datastore cache. Since a marker database_cacheMiss_counter can be seen in the log, we can guess that, the data being requested was not found in the system's cache, and had to be retrieved from the datastore.

6.
```
[2023-02-24T14:40:41.340Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [GET] 'test_whisks' finding document: 'id: guest/helloWorldAction' [marker:database_getDocument_start:525]
```
The application retrieves the helloWorldAction document from the test_whisks CouchDB database.

7.
```
[2023-02-24T14:40:41.361Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [marker:database_getDocument_finish:546:21]
```
The retrieval of the document has finished. 

8.
```
[2023-02-24T14:40:41.387Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ActionsApi] action activation id: 64b0b115410849f3b0b115410889f397 [marker:controller_loadbalancer_start:572]
```
This log message indicates that the action activation process has begun, and it provides the activation ID for the action, which is 64b0b115410849f3b0b115410889f397.

9.
```
[2023-02-24T14:40:41.403Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ShardingContainerPoolBalancer] scheduled activation 64b0b115410849f3b0b115410889f397, action 'guest/helloWorldAction@0.0.1' (managed), ns 'guest', mem limit 256 MB (std), time limit 60000 ms (std) to invoker0/owdev-invoker-0
```
This log message provides information about the scheduling of the action activation. It indicates that the activation with ID 64b0b115410849f3b0b115410889f397 is being scheduled for execution on invoker0/owdev-invoker-0, with a memory limit of 256 MB and a time limit of 60000 ms.

10.
```
[2023-02-24T14:40:41.417Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ShardingContainerPoolBalancer] posting topic 'invoker0' with activation id '64b0b115410849f3b0b115410889f397' [marker:controller_kafka_start:602]
```
This log message indicates that the activation with ID 64b0b115410849f3b0b115410889f397 is being posted to invoker0.

11.
```
[2023-02-24T14:40:41.440Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ShardingContainerPoolBalancer] posted to invoker0[0][26] [marker:controller_kafka_finish:622:20]
```
This log message indicates that the activation with ID 64b0b115410849f3b0b115410889f397 has been successfully posted to invoker0.

12.
```
[2023-02-24T14:40:41.444Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ActionsApi] [marker:controller_loadbalancer_finish:628:56]
```
This log message indicates that the action activation process has completed successfully, and it provides the time taken for the process to complete. In this case, it took 56 ms.

#### Invoker Logs

After having invoked an action, I also checked the logs of the invoker pod to better understand what is exactly happening. So, i executed this command:

```
kubectl get logs owdev-invoker-0 -n openwhisk

```

Here are reported the logs retrieved, all of them followed by a clear explanation of what is happening. For more informations about the *Openwhisk datastore cache*, read [this section](#openwisk-datastore-cache)

1.
```
[2023-02-24T14:40:41.488Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [InvokerReactive] [marker:invoker_activation_start:672]
```
This log indicates that an activation of the action has started.

2.
```
[2023-02-24T14:40:41.658Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [WhiskAction] [GET] serving from datastore: CacheKey(guest/helloWorldAction) [marker:database_cacheMiss_counter:842]
```
This entry indicates that a GET request was made to retrieve an action from the data store cache. Since a marker database_cacheMiss_counter can be seen in the log, we can guess that, the data being requested was not found in the system's cache, and had to be retrieved from the datastore.

3.
```
[2023-02-24T14:40:41.658Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [GET] 'test_whisks' finding document: 'id: guest/helloWorldAction, rev: 1-e691be412ca97f52bc6c4a195309feb9' [marker:database_getDocument_start:843]
```
This log indicates that the CouchDB database is being accessed to retrieve the action document with the given id and revision.

4.
```
[2023-02-24T14:40:41.734Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [marker:database_getDocument_finish:919:76]
```
This log indicates that the retrieval of the action document from the database is complete.

5.
```
[2023-02-24T14:40:41.831Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [WhiskAction] write initiated on existing cache entry, invalidating CacheKey(guest/helloWorldAction), tid 7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD, state WriteInProgress
```
This log indicates that a write operation is being initiated on the action cache entry.

6.
```
[2023-02-24T14:40:41.838Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [WhiskAction] write all done, caching CacheKey(guest/helloWorldAction) Cached
```
This log indicates that the write operation on the action cache entry is complete.

7.
```
[2023-02-24T14:40:41.894Z] [INFO] [#tid_sid_invokerWarmup] [KubernetesClient] launching pod wskowdev-invoker-00-257-prewarm-nodejs14 (image:openwhisk/action-nodejs-v14:1.20.0, mem: 256) (timeout: 60s) [marker:invoker_kubeapi.create_start:86186440]
```
This log indicates that a Kubernetes pod is being launched to prewarm the invoker.

8.
```
[2023-02-24T14:40:41.895Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ContainerPool] containerStart containerState: prewarmed container: Some(ContainerId(wskowdev-invoker-00-256-prewarm-nodejs14)) activations: 1 of max 1 action: helloWorldAction namespace: guest activationId: 64b0b115410849f3b0b115410889f397 [marker:invoker_containerStart.prewarmed_counter:1079]
```
This log indicates that a container called "wskowdev-invoker-00-256-prewarm-nodejs14" is being started to handle an activation of the "helloWorldAction" function. The container is part of a container pool, which ensures that there is always at least one container available to handle requests. The activation is identified by an activation ID of "64b0b115410849f3b0b115410889f397".

9.
```
[2023-02-24T14:40:41.949Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [KubernetesContainer] sending initialization to ContainerId(wskowdev-invoker-00-256-prewarm-nodejs14) ContainerAddress(10.42.0.191,8080) [marker:invoker_activationInit_start:1134]
```
This log indicates that the container is being initialized with the necessary dependencies to run the "helloWorldAction" function.

10.
```
[2023-02-24T14:40:42.027Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [KubernetesContainer] initialization result: ok [marker:invoker_activationInit_finish:1210:76]
```
This log indicates that the container initialization was successful.

11.
```
[2023-02-24T14:40:42.027Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [KubernetesContainer] sending arguments to /guest/helloWorldAction at ContainerId(wskowdev-invoker-00-256-prewarm-nodejs14) ContainerAddress(10.42.0.191,8080) [marker:invoker_activationRun_start:1211]
```
This log indicates that the arguments required to run the "helloWorldAction" function are being sent to the container.

12.
```
[2023-02-24T14:40:42.039Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [KubernetesContainer] running result: ok [marker:invoker_activationRun_finish:1222:10]
```
This log indicates that the "helloWorldAction" function has been executed successfully within the container.

13.
```
[2023-02-24T14:40:42.046Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ContainerProxy] [marker:invoker_collectLogs_start:1230]
```
This log indicates that the container proxy has started collecting logs. The [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] is likely a thread ID, and invoker_collectLogs_start is a marker used to track this specific event in the logs.

14.
```
[2023-02-24T14:40:42.078Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [ContainerProxy] [marker:invoker_collectLogs_finish:1262:30]
```
This log indicates that the container proxy has finished collecting logs. The invoker_collectLogs_finish marker is used to track the end of this event in the logs. The timestamp is slightly later than the start log, indicating that this event took around 30ms to complete.

15.
```
[2023-02-24T14:40:42.081Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [PUT] 'test_activations' saving document: 'id: guest/64b0b115410849f3b0b115410889f397, rev: null' [marker:database_saveDocument_start:1265]
```
This log indicates that the CouchDbRestStore is saving a document to a database named 'test_activations'. The document has an ID of 'guest/64b0b115410849f3b0b115410889f397' and a null revision. The database_saveDocument_start marker is used to track the start of this event in the logs.

16.
```
[2023-02-24T14:40:42.082Z] [INFO] [#tid_sid_dbBatcher] [CouchDbRestStore] 'test_activations' saving 1 documents [marker:database_saveDocumentBulk_start:86186627]
```
This log appears to be related to the same event as the previous log. It indicates that the CouchDbRestStore is saving one document to the 'test_activations' database, and the database_saveDocumentBulk_start marker is used to track the start of this event in the logs. The [#tid_sid_dbBatcher] is likely another thread ID.

17.
```
[2023-02-24T14:40:42.103Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [MessagingActiveAck] posted completion of activation 64b0b115410849f3b0b115410889f397
```
This log indicates that the serverless function with ID 64b0b115410849f3b0b115410889f397 has been completed and its execution status has been communicated to the messaging system.

18.
```
[2023-02-24T14:40:42.105Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [MessagingActiveAck] posted result of activation 64b0b115410849f3b0b115410889f397 
```
This log indicates that the result of the execution of the serverless function with ID 64b0b115410849f3b0b115410889f397 has been communicated to the messaging system.

19.
```
[2023-02-24T14:40:42.126Z] [INFO] [#tid_sid_dbBatcher] [CouchDbRestStore] [marker:database_saveDocumentBulk_finish:86186672:44]
```
This log indicates that a batch of documents has been saved to a database. It is likely that the serverless function is persisting data to a database.

20.
```
[2023-02-24T14:40:42.129Z] [INFO] [#tid_7reXCmR4fHTAwdwlWCMpJ7Tm9tShbiuD] [CouchDbRestStore] [marker:database_saveDocument_finish:1313:47]
```
This log indicates that a single document has been saved to a database. It is likely that the serverless function is persisting data to a database.

## Delete an action

To delete an action in OpenWhisk, we must do:
```
wsk action delete helloWorldAction --insecure
```
I needed to add the insecure tag, since the certificate provided by openwhisk didnìt contain any IP SANs and it was self-signed.

### What happens in OpenWhisk components

### Controller Logs

1. 
```
[2023-02-27T09:27:59.340Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] DELETE /api/v1/namespaces/_/actions/helloWorldAction
```
This log message indicates that a DELETE request was made to the specified API endpoint. The timestamp of the request is given in ISO-8601 format, and the unique thread ID is also provided.

2. 
```
[2023-02-27T09:27:59.349Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [Identity] [GET] serving from datastore: CacheKey(23bc46b1-71f6-4ed5-8c54-816aa4f8c502) [marker:database_cacheMiss_counter:9]
```
This log message indicates that an Identity GET operation was performed on the specified cache key from the datastore. The marker "database_cacheMiss_counter" with a count of 9 indicates that the cache was not present and had to be retrieved from the datastore.

3. 
```
[2023-02-27T09:27:59.349Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [QUERY] 'test_subjects' searching 'subjects.v2.0.0/identities [marker:database_queryView_start:10]
```
This log message indicates that a query was performed on the specified database 'test_subjects' and view 'subjects.v2.0.0/identities'. The marker "database_queryView_start" with a count of 10 indicates the start of the query.

4. 
```
[2023-02-27T09:27:59.407Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [marker:database_queryView_finish:68:58]
```
This log message indicates that the query from the previous log message finished. The marker "database_queryView_finish" with a count of 68:58 indicates the end time of the query.

5. 
```
[2023-02-27T09:27:59.420Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [WhiskAction] [GET] serving from datastore: CacheKey(guest/helloWorldAction) [marker:database_cacheMiss_counter:80]
```
This log message indicates that a GET operation was performed on the specified cache key 'guest/helloWorldAction' from the datastore. The marker "database_cacheMiss_counter" with a count of 80 indicates that the cache was not present and had to be retrieved from the datastore.

6. 
```
[2023-02-27T09:27:59.420Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [GET] 'test_whisks' finding document: 'id: guest/helloWorldAction' [marker:database_getDocument_start:81]
```
This log message indicates that a GET operation was performed on the specified document ID 'guest/helloWorldAction' in the database 'test_whisks'. 

7. 
```
[2023-02-27T09:27:59.438Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [marker:database_getDocument_finish:99:18]
```
This log indicates that a database document has been retrieved successfully. The marker "database_getDocument_finish" suggests that this log is related to the end of the process of fetching a document from the database.

8. 
```
[2023-02-27T09:27:59.453Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [WhiskAction] write initiated on new cache entry
```
This log indicates that a new cache entry is being created. The marker "write initiated" suggests that the log is related to the start of the process of writing to the cache.

9. 
```
[2023-02-27T09:27:59.454Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [WhiskAction] write all done, caching CacheKey(guest/helloWorldAction) Cached
```
This log indicates that the cache entry has been successfully created and cached. The marker "write all done" suggests that this log is related to the end of the process of writing to the cache.

10. 
```
[2023-02-27T09:27:59.459Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [WhiskAction] invalidating CacheKey(guest/helloWorldAction) on delete
```
This log indicates that the cache entry with the key "guest/helloWorldAction" is being invalidated. The marker "invalidating" suggests that this log is related to the start of the process of invalidating the cache entry.

11. 
```
[2023-02-27T09:27:59.460Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [DEL] 'test_whisks' deleting document: 'id: guest/helloWorldAction, rev: 1-e691be412ca97f52bc6c4a195309feb9' [marker:database_deleteDocument_start:121]
```
This log indicates that a document in the database is being deleted. The marker "database_deleteDocument_start" suggests that this log is related to the start of the process of deleting a document from the database.

12. 
```
[2023-02-27T09:27:59.496Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [CouchDbRestStore] [marker:database_deleteDocument_finish:157:36]
```
This log indicates that the document has been successfully deleted from the database. The marker "database_deleteDocument_finish" suggests that this log is related to the end of the process of deleting a document from the database.

13. 
```
[2023-02-27T09:27:59.497Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [WhiskAction] invalidating CacheKey(guest/helloWorldAction)
```
This log indicates that the cache entry with key CacheKey(guest/helloWorldAction) is being invalidated. This means that the cached value for this key is no longer valid and should be removed from the cache.

14. 
```
[2023-02-27T09:27:59.503Z] [INFO] [#tid_bnPJButSUdMerFcGMmM04sLkI9ru4uB4] [BasicHttpService] [marker:http_delete.200_counter:164:164]
```
This log indicates that an HTTP DELETE request was successful (status code 200) and provides a marker with a counter value of 164. It is likely that this request was sent to delete a document from a CouchDB database, based on the previous logs.

#### Invoker Logs

There are no significant logs for the invoker related to this operation. 

## Remove OpenWhisk

If you want to remove OpenWhisk you can do it through Helm.
```
helm -n openwhisk delete owdev
```
Delete all remaining pods.
```
kubectl -n openwhisk delete pod --all
```

Remove the label and the namespace.

```
kubectl label node docker-desktop openwhisk-role-
```
```
kubectl delete namespaces openwhisk
```
## OpenWhisk Deep Dive

Now let's analyze the most important resources created after having deployed OpenWhisk.

### Jobs

#### owdev-install-packages

The job [*owdev-install-packages*](./sample-yaml/owdev-install-packages-job.yaml)manages the creation of almost one pod, which waits for at least one invoker to be availabe (in particular, this is done in the initContainers) and then executes the code in [*myTask.sh*](./../openwhisk-deploy-kube/helm/openwhisk/configMapFiles/installPackages/myTask.sh), mounted as a volume with the ConfigMap [*owdev-install-packages*](./sample-yaml/owdev-install-packages-cm.yaml) which manages to:

1. Install Route Mgmt Support
2. Install the OpenWhisk Catalog
3. Install catalogs for each enabled Event Provider
4. Install the catalog for the Alarm provider
5. Install the catalog for the Kafka provider

#### owdev-gen-certs
This job is creates a pod owdev-gen-certs-<randomId>. It can be found [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-job.yaml). Being more precise, thanks to this job the cluster can use an already existing certificate for the NGINX server, or, if it doesn't exist, it can generate a new one. This is done by mounting as a volume a ConfigMap, which is defined [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-cm.yaml). The whisk external api host name can be found is retrieved from the ConfigMap here [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/ow-whisk-cm.yaml). 
These actions are required to prepare the file'/etc/nginx/nginx.conf', which is the NGINX configuration file,  and the files in '/etc/nginx/certs', which are your certificate files for the NGINX container.

#### owdev-init-couchdb 

The job [*owdev-init-couchdb*](./sample-yaml/owdev-init-couchdb-job.yaml) manages the creation of almost one pod, in which some environment variables with useful parameters to access the database are mounted from the ConfigMap [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). Then, it executes the code in [*initdb.sh*](./../openwhisk-deploy-kube/helm/openwhisk/configMapFiles/initCouchDB/initdb.sh), mounted as a volume with the ConfigMap [*owdev-init-couchdb*](./sample-yaml/owdev-init-couchdb-cm.yaml), which manages to:

1. Clone OpenWhisk to get the ansible playbooks needed to initialize CouchDB
2. Install the secrets whisk.auth.guest and whisk.auth.system into the cloned tree after removing the defaults inherited from the checkout of openwhisk
3. Sanity check: all subjects must have unique keys
4. generate db_local.ini so the ansible jobs know how to access the database
5. Wait for CouchDB to be available before starting to configure it
6. Enable single node mode (this also creates the system databases)
7. Disable reduce limits on views
8. Initialize the DB tables for OpenWhisk

### Deployments

### owdev-couchdb

[This](./sample-yaml/owdev-couchdb-deployment) is the deployment responsible for the creation of a Pod where the couchDB image is running.  Some environment variables with useful parameters to access the database are mounted from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). It also mount a volume with a persistent volume claim [*owdev-couchdb-pvc*](./sample-yaml/owdev-couchdb-pvc.yaml),
which asks for 256Mi of storage and can be accessed both in read and write mode.

### owdev-redis

[This](./sample-yaml/owdev-redis-deployment.yaml) is the deployment responsible for the creation of a Pod where the redis image is running. It mounts a volume with a persistent volume claim [*owdev-redis-pvc*](./sample-yaml/owdev-redis-pvc.yaml), which asks for 2Gi of storage and can be accessed both in read and write mode. 
Redis is an open-source, in-memory data structure store that is commonly used as a database, cache, and message broker. It is often used in high-performance applications that require low-latency access to data, as it is designed to deliver fast read and write performance by keeping data in memory.
In OpenWhisk, Redis is used as a cache to improve the performance of the platform. Specifically, Redis is used to cache the results of previous function executions, so that subsequent requests for the same function can be served more quickly. This is achieved by storing the result of a function execution in Redis, along with a unique identifier for the function and the input arguments that were passed to it.
When a new request is received for the same function with the same input arguments, OpenWhisk checks if the result is already present in the Redis cache. If it is, OpenWhisk can immediately return the cached result, without having to execute the function again. This can significantly improve the response time of the platform, especially for functions that are frequently executed with the same input arguments.
In addition to caching function results, Redis is also used by OpenWhisk for other purposes, such as storing authentication tokens and rate limiting information. Redis is a popular choice for these types of use cases because of its fast read and write performance, its support for complex data structures, and its ability to scale horizontally across multiple nodes.

### owdev-alarmprovider

[This](./sample-yaml/owdev-alarmprovider-deployment) is the deployment responsible for the creation of a Pod where the alarm provider image is running. OpenWhisk Alarm Provider is a service that allows you to schedule the execution of OpenWhisk actions at specified times or intervals. This provider allows you to create alarms that are triggered at a specific date and time, as well as to set up recurring alarms that are triggered at regular intervals.
There are some environment variables with useful parameters to access the database mounted from the ConfigMaps [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml) and [*owdev-whisk.config*](./sample-yaml/owdev-wishk.config.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). It also mounts a volume with a persistent volume claim [*owdev-alarmprovider-pvc*](./sample-yaml/owdev-alarmprovider-pvc.yaml), which asks for 1Gi of storage and can be accessed both in read and write mode.
It also has an init container *wait-for-controller* that waits for the controller service to be up and running.

### owdev-nginx

[This](./sample-yaml/owdev-nginx-deployment) is the deployment responsible for the creation of a Pod where the nginx server image is running. 
It also mounts some volumes from the ConfigMap [*owdev-nginx*](./sample-yaml/owdev-nginx-cm.yaml), from the Secret [*owdev-nginx*](./sample-yaml/owdev-nginx-secret.yaml) and from an EmptyDir called *logs*.
It also has an init container *wait-for-controller* that waits for the controller service to be up and running.

### owdev-kafkaprovider

[This](./sample-yaml/owdev-kafkaprovider-deployment) is the deployment responsible for the creation of a Pod where the kafka provider image is running, an Apache OpenWhisk event provider service for Kafka message queues. With the Kafka provider, you can create an OpenWhisk trigger that is associated with a Kafka topic. Whenever a new message is produced to that Kafka topic, the Kafka provider will automatically create a new event in OpenWhisk and trigger the associated serverless function. This allows you to build event-driven serverless applications that can respond in real-time to events that are generated by other systems. 
There are some environment variables with useful parameters to access the database mounted from the ConfigMaps [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml) and [*owdev-whisk.config*](./sample-yaml/owdev-wishk.config.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). 
It also has an init container *wait-for-controller* that waits for the controller service to be up and running.
### StatefulSets

### owdev-zookeeper

[This](./sample-yaml/owdev-zookeeper-statefulset.yaml) is the StatefulSet responsible for the creation of a Pod for each node (in our case is just one) where the zookeper image is running. It mounts a volume with a persistent volume claim [*owdev-zookeeper-pvc-data*](./sample-yaml/owdev-zookeeper-pvc-data.yaml), which stores the data of zookeeper and asks for 256Mi of storage and can be accessed both in read and write mode, another volume  with a persistent volume claim [*owdev-zookeeper-pvc-datalog*](./sample-yaml/owdev-zookeeper-pvc-datalog.yaml), which stores the logs of zookeeper and asks for 256Mi of storage and can be accessed both in read and write mode. The configuration parameters are taken from the ConfigMap [*owdev-zookeeper*](./sample-yaml/owdev-zookeeper-cm.yaml).

Apache ZooKeeper is an open-source distributed coordination service used for building and managing distributed systems. It is designed to help with tasks such as maintaining configuration information, providing distributed synchronization, and electing a leader among multiple nodes in a distributed system.

ZooKeeper provides a simple and reliable way to manage the coordination of distributed applications. It works by maintaining a hierarchical namespace of data nodes, which can be used to store configuration information, synchronization data, and other kinds of metadata. Clients can watch for changes to these data nodes and receive notifications when they are updated, allowing them to coordinate their actions with other parts of the system.

ZooKeeper is often used in distributed systems such as Apache Hadoop, Apache Kafka, and Apache Storm. Its ease of use, reliability, and scalability make it a popular choice for building and managing distributed systems.

### owdev-kafka

[This](./sample-yaml/owdev-kafka-statefulset.yaml) is the StatefulSet responsible for the creation of a Pod (in our case is just one) where the kafka server image is running.  It mounts a volume with a persistent volume claim [*owdev-kafka-pvc*](./sample-yaml/owdev-kafka-pvc.yaml), which stores the data of zookeeper and asks for 512Mi of storage and can be accessed both in read and write mode. It also has an init container that waits for the Zookeeper service to be up and running. 

### owdev-controller

[This](./sample-yaml/owdev-controller-statefulset.yaml) is the StatefulSet responsible for the creation of a Pod (in our case is just one) where the controller image is running. 
There are some environment variables with useful parameters to access the database mounted from the ConfigMaps [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml) and [*owdev-whisk.config*](./sample-yaml/owdev-whisk.config.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml).
A lot of other environment variables with parameters related to OpenWhisk are set, like for example the *RUNTIMES_MANIFEST*, which contains a JSON document contains the list of available runtimes in OpenWhisk, which can be used to execute serverless functions. For each runtime (e.g. Node.js, Python, Swift, Java, PHP, Ruby), there is a list of versions, and for each version there are some details such as the Docker image that should be used to execute functions written in that language and version, whether the version is the default one or not, whether the version is deprecated or not, and whether an attachment (e.g. a code file or a JAR file) is required for the function to execute.

It also has an init container *wait-for-kafka* that waits for the KAFKA service to be up and running and another init container *wait-for-couchdb*, that waits for couchDB to be up and running. 

If the PodDisruptionBudget is enabled and we have more than one controller pod running, a [*controller-pdb*](./../openwhisk-deploy-kube/helm/openwhisk/templates/controller-pdb.yaml) PodDistruptionBudget resource is also defined, to limit the number of concurrent disruptions that your application experiences, allowing for higher availability while permitting the cluster administrator to manage the clusters nodes.

### owdev-invoker

[This](./sample-yaml/owdev-invoker-statefulset.yaml) is the StatefulSet responsible for the creation of a Pod (in our case is just one) where the invoker image is running. 
There are some environment variables with useful parameters to access the database mounted from the ConfigMaps [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml) and [*owdev-whisk.config*](./sample-yaml/owdev-whisk.config.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml).
A lot of other environment variables with parameters related to OpenWhisk are set, like for example the *RUNTIMES_MANIFEST*, which contains a JSON document contains the list of available runtimes in OpenWhisk, which can be used to execute serverless functions. For each runtime (e.g. Node.js, Python, Swift, Java, PHP, Ruby), there is a list of versions, and for each version there are some details such as the Docker image that should be used to execute functions written in that language and version, whether the version is the default one or not, whether the version is deprecated or not, and whether an attachment (e.g. a code file or a JAR file) is required for the function to execute.

It also has an init container *wait-for-controller* that waits for the controller service to be up and running.

If the PodDisruptionBudget is enabled and we have more than one controller pod running, a [*invoker-pdb*](./../openwhisk-deploy-kube/helm/openwhisk/templates/invoker-pdb.yaml) PodDistruptionBudget resource is also defined, to limit the number of concurrent disruptions that your application experiences, allowing for higher availability while permitting the cluster administrator to manage the clusters nodes.
### Services

#### owdev-couchdb

[This](./sample-yaml/owdev-couchdb-service.yaml) is the service that can be used to access to the couchdb service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.

#### owdev-redis

[This](./sample-yaml/owdev-redis-service.yaml) is the service that can be used to access to the redis service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.

#### owdev-zookeeper
[This](./sample-yaml/owdev-zookeeper-svc.yaml) is the service that can be used to access to the zookeeper service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.
There are three ports defined in the Service object:

1. Port with name *zookeeper* is the default port used by ZooKeeper for client connections, which is used for communication between clients and ZooKeeper instances.
2. Port with name *server* is used for communication between ZooKeeper instances in a cluster, typically for leader election and state replication.
3. Port with name *leader-election* is used for leader election between ZooKeeper instances.

### owdev-kafka
[This](./sample-yaml/owdev-kafka-svc.yaml) is the service that can be used to access to the kafka service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.

### owdev-controller
[This](./sample-yaml/owdev-controller-svc.yaml) is the service that can be used to access to the controller service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.

#### owdev-nginx
[This](./sample-yaml/owdev-nginx-svc.yaml) is the service that can be used to access to the nginx service. It is exposed as a ClusterIp, so it can be reached only from inside the cluster.
There are two ports defined in the Service object:

1. Port with name *http* is the port used by clients to connect to the nginx server with the http protocol.
2. Port with name *https* is the port used by clients to connect to the nginx server with the https protocol.
### Pods

#### owdev-wskadmin

The wskadmin utility is handy for performing various administrative operations against an OpenWhisk deployment. It allows you to create a new subject, manage their namespaces, to block a subject or delete their record entirely. It also offers a convenient way to dump the asset, activation or subject databases and query their views. This is useful for debugging local deployments. Lastly, it is a convenient way to inspect the system logs, or retrieve logs specific to a component or transaction id.

Since wskadmin requires credentials for direct access to the database (that is not normally accessible to the outside), it is deployed in a pod inside Kubernetes that is configured with the proper parameters. You can run wskadmin with kubectl. You need to use the <namespace> and the deployment <name> that you configured with --namespace and --name when deploying.

In this pod, as we can see from its [yaml file](./sample-yaml/owdev-wskadmin.yaml), some environment variables with useful parameters to access the database are mounted from the ConfigMap [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). It is also possible to see that the Kubernetes control plane (specifically, the ServiceAccount admission controller) adds a projected volume to Pods, and this volume includes a token for Kubernetes API access. A section really similar to the following could be found in the yaml file related to the pod we are analyzing:

```
  - name: kube-api-access-<random-suffix>
    projected:
      sources:
        - serviceAccountToken:
            path: token # must match the path the app expects
        - configMap:
            items:
              - key: ca.crt
                path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
              - fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
                path: namespace
```
After having deployed OpenWhisk, the status of this pod is **Running**.

You can then invoke wskadmin with:

```
kubectl -n <namespace> -ti exec <name>-wskadmin -- wskadmin <parameters>
```

For example, is your deployment name is owdev and the namespace is openwhisk you can list users in the guest namespace with:
```
$ kubectl -n openwhisk  -ti exec owdev-wskadmin -- wskadmin user list guest
```
### wskowdev-invoker-00-<instancenumber>-prewarm-nodejs14

This pod is created by system controller component. In this particular case, the Pod is a pre-warmed Pod that has been created in advance of any action being invoked. The pre-warming process helps reduce the startup time for an action when it is first invoked. When an action is invoked, OpenWhisk will select a pre-warmed Pod to run the code for the action, which can help improve the response time for the action.

It is also possible to see that the Kubernetes control plane (specifically, the ServiceAccount admission controller) adds a projected volume to Pods, and this volume includes a token for Kubernetes API access. A section really similar to the following could be found in the yaml file related to the pod we are analyzing:

```
  - name: kube-api-access-<random-suffix>
    projected:
      sources:
        - serviceAccountToken:
            path: token # must match the path the app expects
        - configMap:
            items:
              - key: ca.crt
                path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
              - fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
                path: namespace
```

#### owdev-gen-certs-<randomId>

This pod is created by the job owdev-gen-certs, which can be found [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-job.yaml). Being more precise, thanks to this job the cluster can use an already existing certificate for the NGINX server, or, if it doesn't exist, it can generate a new one. This is done by mounting as a volume a ConfigMap, which is defined [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-cm.yaml). The whisk external api host name can be found is retrieved from the ConfigMap here [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/ow-whisk-cm.yaml). 
These actions are required to prepare the file'/etc/nginx/nginx.conf', which is the NGINX configuration file,  and the files in '/etc/nginx/certs', which are your certificate files for the NGINX container.

After having deployed OpenWhisk, the status of this pod is **Completed**.

#### owdev-install-packages-<randomId>
This pod is created by the job owdev-install-packages, which can be found [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/install-packages-job.yaml). Its function is described in [this section](#owdev-install-packages).

After having deployed OpenWhisk, the status of this pod is **Completed**.

#### owdev-init-couchdb-<randomId> 
This pod is created by the job owdev-init-couchdb, which can be found [here](./../openwhisk-deploy-kube/helm/openwhisk/templates/init-couchdb-job.yaml). Its function is described in [this section](#owdev-init-couchdb).

After having deployed OpenWhisk, the status of this pod is **Completed**.

### owdev-couchdb-<randomId>

This pod is created by the deployment [*owdev-couchdb*](./sample-yaml/owdev-couchdb-deployment.yaml). Its function is described in [this section](#owdev-couchdb). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-redis-<randomId>

This pod is created by the deployment [*owdev-redis*](./sample-yaml/owdev-redis-deployment.yaml). Its function is described in [this section](#owdev-redis). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-zookeeper-<randomId>

This pod is created by the StatefulSet [*owdev-zookeeper*](./sample-yaml/owdev-zookeeper-statefulset.yaml). Its function is described in [this section](#owdev-zookeeper). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-kafka-<randomId>

This pod is created by the StatefulSet [*owdev-kafka*](./sample-yaml/owdev-kafka-statefulset.yaml). Its function is described in [this section](#owdev-kafka). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-controller-<randomId>

This pod is created by the StatefulSet [*owdev-controller*](./sample-yaml/owdev-controller-statefulset.yaml). Its function is described in [this section](#owdev-controller). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-alarmprovider-<randomId>

This pod is created by the Deployment [*owdev-alarmprovider*](./sample-yaml/owdev-alarmprovider-deployment.yaml). Its function is described in [this section](#owdev-alarmprovider). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-invoker-<randomId>

This pod is created by the StatefulSet [*owdev-invoker*](./sample-yaml/owdev-invoker-statefulset.yaml). Its function is described in [this section](#owdev-invoker). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-nginx-<randomId>

This pod is created by the Deployment [*owdev-nginx*](./sample-yaml/owdev-nginx-deployment.yaml). Its function is described in [this section](#owdev-nginx). 

After having deployed OpenWhisk, the status of this pod is **Running**.

### owdev-kafkaprovider-<randomId>

This pod is created by the Deployment [*owdev-kafkaprovider*](./sample-yaml/owdev-kafkaprovider-deployment.yaml). Its function is described in [this section](#owdev-kafkaprovider). 

After having deployed OpenWhisk, the status of this pod is **Running**.

## Additional informations

### Openwisk datastore cache

OpenWhisk has a datastore cache that is used to improve the performance of function invocations by reducing the number of requests to the underlying data store.

The datastore cache in OpenWhisk is implemented using Apache CouchDB's built-in caching mechanism, which is based on a Least Recently Used (LRU) algorithm. This caching mechanism is used to cache the metadata associated with triggers, rules, and packages, as well as the code and runtime environment associated with actions.

When a function is invoked, OpenWhisk first checks if the metadata associated with the function is available in the datastore cache. If it is, OpenWhisk retrieves the cached metadata instead of making a request to the data store, which can significantly reduce the latency of function invocations. Similarly, when a function is first invoked, OpenWhisk caches the function's code and runtime environment in the datastore cache, so that subsequent invocations of the function can be executed more quickly.

It's worth noting that the datastore cache in OpenWhisk is not configurable by users, as it is implemented by Apache CouchDB and is automatically used by OpenWhisk as part of its runtime environment.

### ShardingContainerPoolBalancer 
A loadbalancer that schedules workload based on a hashing-algorithm.
Reference : [https://github.com/adobe-apiplatform/incubator-openwhisk/blob/master/core/controller/src/main/scala/org/apache/openwhisk/core/loadBalancer/ShardingContainerPoolBalancer.scala](https://github.com/adobe-apiplatform/incubator-openwhisk/blob/master/core/controller/src/main/scala/org/apache/openwhisk/core/loadBalancer/ShardingContainerPoolBalancer.scala)
 
  ## Algorithm
 
  At first, for every namespace + action pair a hash is calculated and then an invoker is picked based on that hash
  (`hash % numInvokers`). The determined index is the so called "home-invoker". This is the invoker where the following
  progression will **always** start. If this invoker is healthy (see "Invoker health checking") and if there is
  capacity on that invoker (see "Capacity checking"), the request is scheduled to it.
 
  If one of these prerequisites is not true, the index is incremented by a step-size. The step-sizes available are the
  all coprime numbers smaller than the amount of invokers available (coprime, to minimize collisions while progressing
  through the invokers). The step-size is picked by the same hash calculated above (`hash & numStepSizes`). The
  home-invoker-index is now incremented by the step-size and the checks (healthy + capacity) are done on the invoker
  we land on now.
 
  This procedure is repeated until all invokers have been checked at which point the "overload" strategy will be
  employed, which is to choose a healthy invoker randomly. In a steadily running system, that overload means that there
  is no capacity on any invoker left to schedule the current request to.
 
  If no invokers are available or if there are no healthy invokers in the system, the loadbalancer will return an error
  stating that no invokers are available to take any work. Requests are not queued anywhere in this case.
 
  An example:
  - availableInvokers: 10 (all healthy)
  - hash: 13
  - homeInvoker: hash % availableInvokers = 13 % 10 = 3
  - stepSizes: 1, 3, 7 (note how 2 and 5 is not part of this because it's not coprime to 10)
  - stepSizeIndex: hash % numStepSizes = 13 % 3 = 1 => stepSize = 3
 
  Progression to check the invokers: 3, 6, 9, 2, 5, 8, 1, 4, 7, 0 --> done
 
  This heuristic is based on the assumption, that the chance to get a warm container is the best on the home invoker
  and degrades the more steps you make. The hashing makes sure that all loadbalancers in a cluster will always pick the
  same home invoker and do the same progression for a given action.
 
  Known caveats:
  - This assumption is not always true. For instance, two heavy workloads landing on the same invoker can override each
    other, which results in many cold starts due to all containers being evicted by the invoker to make space for the
    "other" workload respectively. Future work could be to keep a buffer of invokers last scheduled for each action and
    to prefer to pick that one. Then the second-last one and so forth.
 
  ## Capacity checking
 
  The maximum capacity per invoker is configured using `user-memory`, which is the maximum amount of memory of actions
  running in parallel on that invoker.
 
  Spare capacity is determined by what the loadbalancer thinks it scheduled to each invoker. Upon scheduling, an entry
  is made to update the books and a slot for each MB of the actions memory limit in a Semaphore is taken. These slots
  are only released after the response from the invoker (active-ack) arrives **or** after the active-ack times out.
  The Semaphore has as many slots as MBs are configured in `user-memory`.
 
  Known caveats:
  - In an overload scenario, activations are queued directly to the invokers, which makes the active-ack timeout
    unpredictable. Timing out active-acks in that case can cause the loadbalancer to prematurely assign new load to an
    overloaded invoker, which can cause uneven queues.
  - The same is true if an invoker is extraordinarily slow in processing activations. The queue on this invoker will
    slowly rise if it gets slow to the point of still sending pings, but handling the load so slowly, that the
    active-acks time out. The loadbalancer again will think there is capacity, when there is none.
 
  Both caveats could be solved in future work by not queueing to invoker topics on overload, but to queue on a
  centralized overflow topic. Timing out an active-ack can then be seen as a system-error, as described in the
  following.
 
  ## Invoker health checking
 
  Invoker health is determined via a kafka-based protocol, where each invoker pings the loadbalancer every second. If
  no ping is seen for a defined amount of time, the invoker is considered "Offline".
 
  Moreover, results from all activations are inspected. If more than 3 out of the last 10 activations contained system
  errors, the invoker is considered "Unhealthy". If an invoker is unhealthy, no user workload is sent to it, but
  test-actions are sent by the loadbalancer to check if system errors are still happening. If the
  system-error-threshold-count in the last 10 activations falls below 3, the invoker is considered "Healthy" again.
 
  To summarize:
  - "Offline": Ping missing for > 10 seconds
  - "Unhealthy": > 3 **system-errors** in the last 10 activations, pings arriving as usual
   "Healthy": < 3 **system-errors** in the last 10 activations, pings arriving as usual
 
  ## Horizontal sharding
 
  Sharding is employed to avoid both loadbalancers having to share any data, because the metrics used in scheduling
  are very fast changing.
 
  Horizontal sharding means, that each invoker's capacity is evenly divided between the loadbalancers. If an invoker
  has at most 16 slots available (invoker-busy-threshold = 16), those will be divided to 8 slots for each loadbalancer
  (if there are 2).
 
  If concurrent activation processing is enabled (and concurrency limit is > 1), accounting of containers and
  concurrency capacity per container will limit the number of concurrent activations routed to the particular
  slot at an invoker. Default max concurrency is 1.
 
  Known caveats:
  - If a loadbalancer leaves or joins the cluster, all state is removed and created from scratch. Those events should
    not happen often.
  - If concurrent activation processing is enabled, it only accounts for the containers that the current loadbalancer knows.
    So the actual number of containers launched at the invoker may be less than is counted at the loadbalancer, since
    the invoker may skip container launch in case there is concurrent capacity available for a container launched via
    some other loadbalancer.
 

**TODO** : check all AFFINITIES!