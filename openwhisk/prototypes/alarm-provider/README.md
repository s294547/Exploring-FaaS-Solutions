# ALARM PROVIDER

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)

## Introduction

This folder contains an explanation of how I solved some issues related to the Openwhisk Alarm Provider.

I found out some issues: when making requests to the OpenWhisk API Host, as we can see in [this file](./openwhisk-package-alarms-master/provider/lib/utils.js) where we can find the code line *this.uriHost ='https://' + this.routerHost;*. The problem is that the alarm provider deployment uses the *whisk_internal_api_host_nameAndPort* to set the value of the *ROUTER_HOST* and *ENDPOINT_AUTH* ([code here](https://github.com/apache/openwhisk-deploy-kube/blob/master/helm/openwhisk/templates/provider-alarm-pod.yaml)). In the end what happens is that the alarm provider contacts a port that is not secured (80) using https.

We have two ways to solve this issue: 
1. Change the alarm provider code, so that the url will include the http protocol. 
2. Change the structure of the alarm provider deployment, so that it will be using the *whisk_external_api_host_nameAndPort*.

I will follow the second strategy, because the first one would require me to mantain the patched alarm provider.