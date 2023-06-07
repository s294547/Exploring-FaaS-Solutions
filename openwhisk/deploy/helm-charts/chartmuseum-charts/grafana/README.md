# GRAFANA - CHARTMUSEUM

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Grafan Data Source](#grafana-data-source)
3. [Grafana Dashboard](#grafana-dashboard)

## Introduction

This chart is an extension of another Grafana chart, which can be found in this [folder](./../original-charts/grafana-master/). 

In this file I will just present and explain the add-ons of the chart.

## Grafana Data Source
 
This chart has an additional template file, which is called [06 - grafanadatasource.yml](./templates/05%20-%20grafanadatasource.yml), which creates a grafana data source of type InfluxDB from which the data to be presented on the dasboards are taken.

Some additional paramters are provided in [values.yaml](./values.yaml) file, for example:

```
influx:
  enabled: true
  token: ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ
  organization: influxdata
  bucket: aggregates
  url: http://influxdb-influxdb2:80
```

## Grafana Dashboard
This chart has an additional template file, which is called [06 - grafanadashboard.yml](./templates/05%20-%20grafanadatasource.yml), which creates a grafana dashboard that shows some aggregate data.

Some additional paramters are provided in [values.yaml](./values.yaml) file, for example:

```
dashboard:
  enabled: true
```