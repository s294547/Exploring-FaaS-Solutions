# OPENWHISK -  ACTIONS AND TRIGGERS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Code Explanation](#code-explanation)


## Introduction

This folder contains the code of the OpenWhisk actions that will be created.

You will find some files:
1. [aggregatesGasAvgAction.js]: the code of the action that computes the mean gas percentage in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
2. [aggregatesGasMinAction.js]: the code of the action that computes the min gas percentage  in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
3. [aggregatesGasMaxAction.js]: the code of the action that computes the max gas percentage  in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
4. [aggregatesTemperatureAvgAction.js]: the code of the action that computes the mean temperature in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
5. [aggregatesTemperatureMinAction.js]: the code of the action that computes the min temperature  in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
6. [aggregatesTemperatureMaxAction.js]: the code of the action that computes the max temperature in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
7. [aggregatesHumidityAvgAction.js]: the code of the action that computes the mean humidity in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
8. [aggregatesHumidityMinAction.js]: the code of the action that computes the min humidity in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.
9. [aggregatesHumidityMaxAction.js]: the code of the action that computes the max humidity in the last 30 minutes from local data and sends them to the centralized InfluxDB instance.

## Code Explanation

The folder contains Node.js scripts that extract data from an InfluxDB instance, compute aggregates considering the data of the last 30 minutes for certain measurements, and write the results to another InfluxDB instance.

The scripts first extract the required parameters from the params object, including the URLs, tokens, organization, and bucket for both the local and central InfluxDB instances. They then compute the date range for the query based on the current time and the last 30 minutes.

The scripts then construct an InfluxDB Flux query to compute different aggregates, for example the mean, max, and min values for the "gas_perc", "humidity", and "temperature" measurements, grouped by "datacenter_id" and "_measurement". The query is then executed on the local InfluxDB instance using the request library.

The results of the query are processed by splitting the output into rows and columns and extracting the values needed, like mean, max, and min values for each measurement and each "datacenter_id". These values are then used to construct InfluxDB line protocol strings, which are written to the central InfluxDB instance using another request to the /api/v2/write endpoint.

The parameters are:
- **local_url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<localInfluxDBClusterIPServiceName>:<localInfluxDBClusterIpServicePort>"
- **local_token**: the token of the local influxdb instance.
- **local_org**: the organization of the local influxDB instance.
- **local_bucket**: the bucket of the local InfluxDB instance.
- **central_url**: the url to contact the centralized InfluxDB. The parameter must have te following format: "https://<influxDbIngressRouteName>"
- **central_token**: the token of the centralized influxdb instance.
- **central_org**: the organization of the centralized influxDB instance.
- **local_bucket**: the bucket of the centralized InfluxDB instance.
