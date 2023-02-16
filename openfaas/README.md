# OPENFAAS

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
	1. [Arkade](#arkade)
	2. [OpenFaaS CLI](#openfaas-cli)
3. [Deploy OpenFaaS](#deploy-openfaas)
	1. [Create a namespace](#create-a-namespace)
    2. [Deploy OpenFaaS with Arkade](#deploy-openfaas-with-arkade)
	3. [Create an IngressRoute for the opeenfaas gateway](#create-an-ingressroute-for-the-openfaas-gateway)
    4. [Retrieve and save your password](#retreieve-and-save-your-password)
4. [Create a function](#create-a-function)
5. [Invoke a function](#invoke-a-function)

## Introduction
This file will document all the steps required to deploy OpenFaaS on a given Kubernetes Cluster.
This example was done using Docker Desktop on Windows 11 with Ubuntu 22 WSL 2. 
It will also be reported an example of how to create a function with OpenFaaS

The repository up to now will just keep a *appfleet-hello-world-right.yaml* file and a directory *appfleet-hello-world-right* with the code of the Node.js function *appfleet-hello-world-right.js*.  

## Required Tools Installation
### Arkade
We will use Arkade to deploy OpenFaaS on Kubernetes so let’s install it.

```
curl -sSL https://get.arkade.dev | sudo -E sh
```
### OpenFaaS CLI
Install the faas cli.

```
arkade get faas-cli
```


## Deploy OpenFaaS


### Create a namespace
Create a Kubernetes namespace for OpenFaaS.

```
kubectl create namespace openfaas
```

### Deploy OpenFaaS with Arkade

Deploy OpenFaaS using Arkade.

```
arkade install openfaas
```
### Create an IngressRoute for the opeenfaas gateway

An IngressRoute should be created to have acceess to OpenFaaS from an host machine external to the cluster. This can be done creating a yaml file like the following one *ingressroute.yaml*:

```
kind: IngressRoute
metadata:
  creationTimestamp: "2023-02-13T14:00:01Z"
  generation: 1
  labels:
    app: gateway
  name: gateway
  namespace: openfaas
  resourceVersion: "565259"
  uid: 09941c93-80b1-443d-abb4-253ab7dc7958
spec:
  entryPoints:
  - https
  routes:
  - kind: Rule
    match: Host(`gateway-faas.salaolimpo.cloud`)
    services:
    - kind: Service
      name: gateway
      namespace: openfaas
      port: http
```

Then, we have to do;
```
kubectl create -f ingressroute.yaml
```

### Retrieve and save your password

Issue the following command to retrieve your password and save it into an environment variable named PASSWORD:

```
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
```
## Create a Function

This is an example of function creation using a template.

Download the official templates locally
```
faas-cli template pull
```

To create a new serverless function, run the *faas-cli* new command specifying:
The name of your new function (*appfleet-hello-world-right*)
The lang parameter followed by the programming language template (*node*).
```
faas-cli new appfleet-hello-world --lang node
```

At this point, your directory structure should look like the following:
```
tree . -L 2
.
├── appfleet-hello-world-right
│   ├── handler.js
│   └── package.json
├── appfleet-hello-world-right.yml
└── template
    ├── csharp
    ├── csharp-armhf
    ├── dockerfile
    ├── go
    ├── go-armhf
    ├── java11
    ├── java11-vert-x
    ├── java8
    ├── node
    ├── node-arm64
    ├── node-armhf
    ├── node12
    ├── php7
    ├── python
    ├── python-armhf
    ├── python3
    ├── python3-armhf
    ├── python3-debian
    └── ruby

21 directories, 3 files
```

The *appfleet-hello-world-right/handler.js* file contains the code of your serverless function. You can use the echo command to list the contents of this file:

```
cat appfleet-hello-world-right/handler.js
"use strict"

module.exports = async (context, callback) => {
    return {status: "done"}
}
You can specify the dependencies required by your serverless function in the package.json file. The automatically generated file is just an empty shell:
cat appfleet-hello-world/package.json
{
  "name": "function",
  "version": "1.0.0",
  "description": "",
  "main": "handler.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

The spec of the *appfleet-hello-world-right* function is stored in the *appfleet-hello-world-right.yml* file:
```
cat appfleet-hello-world.yml
version: 1.0
provider:
  name: openfaas
  gateway: http://127.0.0.1:8080
functions:
  appfleet-hello-world:
    lang: node
    handler: ./appfleet-hello-world
    image: appfleet-hello-world:latest
```

Correct the values of the gateway, since we are going to use the gateway previously created,  and of the image, since we are going to use a registry inside the cluster:

```
version: 1.0
provider:
  name: openfaas
  gateway: "https://gateway-faas.salaolimpo.cloud"
functions:
  appfleet-hello-world-right:
    lang: node
    handler: ./appfleet-hello-world-right
    image: registry.salaolimpo.cloud/appfleet-hello-world-right:latest
```

With your serverless function pushed to Docker Hub, log in to your local instance of the OpenFaaS gateway by entering the following command:
```
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
```

Run the faas-cli deploy command to deploy your serverless function:
```
faas-cli deploy -f appfleet-hello-world-right.yml
```


## Invoke a function
You can now invoke the action from shell.
```
faas-cli invoke -f appfleet-hello-world-right.yml appfleet-hello-world-right
```


