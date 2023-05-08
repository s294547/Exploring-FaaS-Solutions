# OPENWHISK - CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [NodeJs14 Runtime](#nodejs14-runtime)
3. [Network Policies](#network-policies)
4. [Alarm Provider](#alarm-provider)


## Introduction

This chart is an extension of the official OpenWhisk chart, which can be found with its entire documentation [here](./https://github.com/apache/openwhisk-deploy-kube).

In this file I will just present and explain the add-ons and modifications of the chart.
 
## Nodejs14 Runtime
 
I create a new image for nodejs14 runtime for openwhisk. The one provided by the originaò helm package had some problems (the module *requests* is not installed with npm), so i had to fix it. 

I created a docker image called *giuliabianchi1408/action-nodejs-v14* and then i changed the [runtimes file](./runtimes.json) to use it. 

## Network Policies

I had to extend the network policies provided by Openwhisk, in order to allow the other services that are going to be deployed in the same namespace to talk with each other and to be reached from outside the cluster when needed.

The network policies yaml file is [this one](./templates/network-policy.yaml).

## Alarm Provider

I found out a bug in the alarm provider. In particular, the problem is if using the default image provieded by openwhisk of the alarm provider, the uri of the apiHost is created in this way: this.uriHost ='https://' + this.routerHost;.

If you deploy openwhisk using the default openwhisk helm chart, in the yaml of the alarm provider deployment the ROUTER_HOST and ENDPOINT_AUTH environment variables are using the INTERNAL api host name and port.
This is a problem, since the internal port is 80 and does not provide any security option, but we are using https in the uri.

To solve this problem, i modified the [provider yaml](./templates/provider-alarm-pod.yaml) to use the EXTERNAL api host name and port, which are exposed on a secure port and are capable of using https.

