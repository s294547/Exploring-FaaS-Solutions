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
2. [addReadingsToDB](#addreadingstodb)
3. [aggregatesAction](#aggregatesaction)
4. [feed_action](#feed_action)


## Introduction

This folder contains the code of the OpenWhisk actions that will be created.

You will find three files:
1. [addReadingsToDB.js]: the code of the action that saves the local data in the local InfluxDB instance.
2. [aggregatesAction.js]: the code of the action that computes aggregates from local data and sends them to the centralized InfluxDB instance.
3. [feed_action.js]: the feed action of the mqtt package.

## addReadingsToDB


This is a JavaScript function that sends data to an InfluxDB database. It receives and uses some parameters, which are:

- **url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<influxDBClusterIPServiceName>:<influxDBClusterIpServicePort>"
- **token**: the token of the local influxdb instance.
- **org**: the organization of the local influxDB instance.
- **bucket**: the bucket of the local InfluxDB instance.

## aggregatesAction

This is a Node.js script that extracts data from an InfluxDB instance, computes daily aggregates for certain measurements, and writes the results to another InfluxDB instance.

The script first extracts the required parameters from the params object, including the URLs, tokens, organization, and bucket for both the local and central InfluxDB instances. It then computes the date range for the query based on the current time and the last 30 minutes.

The script then constructs an InfluxDB Flux query to compute the daily mean, max, and min values for the "gas_perc", "humidity", and "temperature" measurements, grouped by "datacenter_id" and "_measurement". The query is then executed on the local InfluxDB instance using the request library.

The results of the query are processed by splitting the output into rows and columns and extracting the mean, max, and min values for each measurement and each "datacenter_id". These values are then used to construct InfluxDB line protocol strings, which are written to the central InfluxDB instance using another request to the /api/v2/write endpoint.

The parameters are:
- **local_url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<localInfluxDBClusterIPServiceName>:<localInfluxDBClusterIpServicePort>"
- **local_token**: the token of the local influxdb instance.
- **local_org**: the organization of the local influxDB instance.
- **local_bucket**: the bucket of the local InfluxDB instance.
- **central_url**: the url to contact the centralized InfluxDB. The parameter must have te following format: "https://<influxDbIngressRouteName>"
- **central_token**: the token of the centralized influxdb instance.
- **central_org**: the organization of the centralized influxDB instance.
- **local_bucket**: the bucket of the centralized InfluxDB instance.

## feed_action

This is a NodeJS script that is responsible of creating, deleting and updating OpenWhisk triggers.



