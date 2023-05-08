# Creating my runtime for nodejs14

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
This folder contains a Dockerfile to create a new image for nodejs14 runtime for openwhisk. The one provided by the helm package had some problems (the module *requests* is not installed with npm), so i had to fix it. 

I created a docker image called *giuliabianchi1408/action-nodejs-v14* and then i changed the [runtimes file](./../../openwhisk-deploy-kube/helm/openwhisk/runtimes.json) to use it. Then i re-deployed the OpenWhisk. 

