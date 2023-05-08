# COUCHDB - CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Ingress Route](#ingress-route)

## Introduction

This chart is an extension of the CouchDB chart provided by Apache, which can be found in this [folder](./../original-charts/couchdb-4.3.1/), where you can find all the extended documentation.

In this file I will just present and explain the add-ons of the chart.

## Ingress Route
 
This chart has an additional template file, which is called [ingress-couchdb.yaml](./templates/ingress-couchdb.yaml), which creates a traefik ingress route to access the CouchDB service from outside the cluster.

To set up CouchDB, some additional paramters are provided in [values.yaml](./values.yaml) file, for example:

```
iroute:
  enabled: true
  gateway: couchdb-gateway.liquidfaas.cloud
```
