# MOSQUITTO - CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [MQTT Provider](#mqtt-provider)


## Introduction

This chart is an extension of another Mosquitto chart, which can be found in this [folder](./../original-charts/mosquitto-0.1.0/). 

In this file I will just present and explain the add-ons of the chart.

 
## MQTT Provider
 
This chart has an additional template file, which is called [provider.yaml](./templates/provider.yaml), which creates a MQTT provider deployment and service.

To set up the MQTT provider, some additional paramters are provided in [values.yaml](./values.yaml) file, for example:

```
provider:
  enabled: true
```