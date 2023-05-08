# INFLUXDB - CHARTMUSEUM

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

This chart is an extension of another InfluxDB chart, which can be found in this [folder](./../original-charts/influxdb2-2.1.1/). 

In this file I will just present and explain the add-ons of the chart.

 
## Ingress Route
 
This chart has an additional template file, which is called [ingress-influxdb.yaml](./templates/ingress-influxdb.yaml), which creates a traefik ingress route to access the InfluxDB service from outside the cluster.

To set up InfluxDB, some additional paramters are provided in [values.yaml](./values.yaml) file, for example:

```
iroute:
  enabled: true
  externalUrl: influxdb.liquidfaas.cloud
```