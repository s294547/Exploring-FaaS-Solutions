# OPENWHISK IN A FAAS ENVIRONMENT

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [System Architecture](#system-architecture)
3. [Setup the External Database](#setup-the-external-database)
4. [Deploy OpenWhisk Centralized Instance](#deploy-openwhisk-centralized-instance)
5. [Deploy OpenWhisk Local Instances](#deploy-openwhisk-local-instances)

## Introduction
This file will document all the steps required to deploy a FaaS solution adopting Openwhisk.


## System Architecture

[arch](./system-arch.png)

Each DC is going to have its own Openwhisk deployment and its own database with the local data. Each Openwhisk deployment will be connected to the same remote instance of CouchDB, so they will have access to the functions defined by every local instance of OpenWhisk. When running a function, it will run exactly in the DC where the function has been triggered/called.

Each instance of OpenWhisk in the clusters will have its own datastore cache. The datastore cache is a local caching layer that sits between the functions and the remote database, and is specific to each OpenWhisk instance.

When a function running on one instance of OpenWhisk accesses the remote database, the data it retrieves is stored in the datastore cache of that instance. If the same function is later invoked on the same instance and requests the same data, the data can be returned from the cache instead of being retrieved from the remote database, which can improve performance.

However, if a function is invoked on a different instance of OpenWhisk than the one it was previously executed on, the data store cache on that instance will not have a copy of the previously retrieved data. Therefore, the function will need to retrieve the data from the remote database again, and the data will be cached in the datastore cache of that instance.

In summary, each instance of OpenWhisk has its own datastore cache, which is specific to that instance and is not shared with other instances.

## Setup the External Database

As external database we will use CouchDB, so we will deploy it on the 'centralized' cluster using Helm charts. 

```
helm install couchdb/couchdb  --version=4.1.0  --set allowAdminParty=true   --set couchdbConfig.couchdb.uuid=$(curl https://www.uuidgenerator.net/api/version4 2>/dev/null | tr -d -)
```

To reach it from other clusters, we need to create a Traefik Ingress Route to reach it. We can find it in the file [*ingress-couchdb.yml*](./ingress-couchdb.yaml).

Example: 
```
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: couchdb
  labels:
    app: couchdb
spec:
  routes:
  - kind: Rule
    match: Host(`couchdb-gateway.liquidfaas.cloud`)
    services:
    - kind: Service
      # the name of the clusterIp service in the cluster
      name: couchdb-external-couchdb
      namespace: couchdb-external
      port: 5984
```
To create the IngressRoute :

```
kubectl create -f ingress-couchdb.yml -n couchdb-external
```


## Deploy Openwhisk Centralized Instance

To deploy the centralized instance of OpenWhisk, we must follow the steps specified in [this file](./../README.md), using a different *mycluster.yml* file, which is [this one](./mycluster.yml). The only thing that changes up to now is the definition of the database used by OpenWhisk as an external one. 

Example:

```
db:
  external: true
  host: "couchdb-gateway.liquidfaas.cloud"
  protocol: "https"
  auth:
    username: "admin"
    password: "password"
  # Should we run a Job to wipe and re-initialize the database when the chart is deployed?
  # This should always be true if external is false.
  wipeAndInit: true
  port: 443
```
In this case, it is importanto to set the *wipeAndInit* field to *true*.

We have also disabled the Kafka provider.

**TO BE REMEMBERED WHEN DEPLOYING OPENWHISK**: if the database is in the same cluster of the openwhisk instance (which is highly recommended when *wipeAndInit* field is *true*), we can simply expose it using its clusterIp and the http protocol (see the file [mycluster.yml](./mycluster.yml)). If the database is in another cluster and has already been initialized, we can connect to it using the traefik IngressRoute. These steps are recommended just to avoid some problems that appeared when deploying the openwhisk instances.


## Deploy Openwhisk Local Instances

To deploy one of the instance of OpenWhisk, we must follow the steps specified in [this file](./../README.md), using a different *mycluster.yml* file, which is [this one](./salaolimpo-openwhisk/mycluster.ymlmycluster.yml). The only thing that changes up to now is the definition of the database used by OpenWhisk as an external one. 

Example:

```
db:
  external: true
  host: "couchdb-gateway.liquidfaas.cloud"
  protocol: "https"
  auth:
    username: "admin"
    password: "password"
  # Should we run a Job to wipe and re-initialize the database when the chart is deployed?
  # This should always be true if external is false.
  wipeAndInit: false
  port: 443
```
In this case, it is importanto to set the *wipeAndInit* field to *false*, since the database has already been initialized by the centralized instance of Openwhisk. 

We have also disabled the Kafka provider.

