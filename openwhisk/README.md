# OPENWHISK

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
6. [Invoke an action](#invoke-an-action)
7. [Remove OpenWhisk](#remove-openwhisk)
8. [OpenWhisk Deep Dive](#openwhisk-deep-dive)
	1. [Jobs](#jobs)
	2. [Deployments](#deployments)
	3. [Stateful Sets](#statefulsets)
	4. [Pods](#pods)

## Introduction
This file will document all the steps required to deploy OpenWhisk on a given Kubernetes Cluster.
This example was done using Docker Desktop on Windows 11 with Ubuntu 22 WSL 2. 
It will also be reported an example of how to create an action in OpenWhisk. 

The repository up to now will just keep the code of the created action *helloWorldAction.js* and an example of **mycluster.yml**.  

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

The job [*owdev-install-packages*](./sample-yaml/owdev-install-packages-job.yaml)manages the creation of almost one pod, which waits for at least one invoker to be availabe (in particular, this is done in the initContainers) and then executes the code in [*myTask.sh*](./openwhisk-deploy-kube/helm/openwhisk/configMapFiles/installPackages/myTask.sh), mounted as a volume with the ConfigMap [*owdev-install-packages*](./sample-yaml/owdev-install-packages-cm.yaml) which manages to:

1. Install Route Mgmt Support
2. Install the OpenWhisk Catalog
3. Install catalogs for each enabled Event Provider
4. Install the catalog for the Alarm provider
5. Install the catalog for the Kafka provider

#### owdev-gen-certs
This job is creates a pod owdev-gen-certs-<randomId>. It can be found [here](./openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-job.yaml). Being more precise, thanks to this job the cluster can use an already existing certificate for the NGINX server, or, if it doesn't exist, it can generate a new one. This is done by mounting as a volume a ConfigMap, which is defined [here](./openwhisk-deploy-kube/helm/openwhisk/templates/gen-certs-cm.yaml). The whisk external api host name can be found is retrieved from the ConfigMap here [here](./openwhisk-deploy-kube/helm/openwhisk/templates/ow-whisk-cm.yaml). 
These actions are required to prepare the file'/etc/nginx/nginx.conf', which is the NGINX configuration file,  and the files in '/etc/nginx/certs', which are your certificate files for the NGINX container.

#### owdev-init-couchdb 

The job [*owdev-init-couchdb*](./sample-yaml/owdev-init-couchdb-job.yaml) manages the creation of almost one pod, in which some environment variables with useful parameters to access the database are mounted from the ConfigMap [*owdev-db.config*](./sample-yaml/owdev-db.conf.yaml), but also from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). Then, it executes the code in [*initdb.sh*](./openwhisk-deploy-kube/helm/openwhisk/configMapFiles/initCouchDB/initdb.sh), mounted as a volume with the ConfigMap [*owdev-init-couchdb*](./sample-yaml/owdev-init-couchdb-cm.yaml), which manages to:

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

[This](./sample-yaml/owdev-couchdb-deployment.yaml) is the deployment responsible for the creation of a Pod where the couchDB image is running.  Some environment variables with useful parameters to access the database are mounted from the Secret [*owdev-db.auth*](./sample-yaml/owdev-db.auth.yaml). It also mount a volume with a persistent volume claim [*owdev-couchdb-pvc*](./sample-yaml/owdev-couchdb-pvc.yaml),
which asks for 256Mi of storage and can be accessed both in read and write mode.

### owdev-redis

[This](./sample-yaml/owdev-redis-deployment.yaml) is the deployment responsible for the creation of a Pod where the redis image is running. It mounts a volume with a persistent volume claim [*owdev-redis-pvc*](./sample-yaml/owdev-redis-pvc.yaml),
which asks for 2Gi of storage and can be accessed both in read and write mode.

### StatefulSets

### owdev-zookeeper

[This](./sample-yaml/owdev-zookeeper-statefulset.yaml) is the StatefulSet responsible for the creation of a Pod where the zookeper image is running. It mounts a volume with a persistent volume claim [*owdev-zookeeper-pvc-data*](./sample-yaml/owdev-zookeeper-pvc-data.yaml), which stores the data of zookeeper and asks for 256Mi of storage and can be accessed both in read and write mode, another volume  with a persistent volume claim [*owdev-zookeeper-pvc-datalog*](./sample-yaml/owdev-zookeeper-pvc-datalog.yaml), which stores the logs of zookeeper and asks for 256Mi of storage and can be accessed both in read and write mode. The configuration parameters are taken from the ConfigMap [*owdev-zookeeper*](./sample-yaml/owdev-zookeeper-cm.yaml).

Apache ZooKeeper is an open-source distributed coordination service used for building and managing distributed systems. It is designed to help with tasks such as maintaining configuration information, providing distributed synchronization, and electing a leader among multiple nodes in a distributed system.

ZooKeeper provides a simple and reliable way to manage the coordination of distributed applications. It works by maintaining a hierarchical namespace of data nodes, which can be used to store configuration information, synchronization data, and other kinds of metadata. Clients can watch for changes to these data nodes and receive notifications when they are updated, allowing them to coordinate their actions with other parts of the system.

ZooKeeper is often used in distributed systems such as Apache Hadoop, Apache Kafka, and Apache Storm. Its ease of use, reliability, and scalability make it a popular choice for building and managing distributed systems.
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

**TODO** : check all AFFINITIES!