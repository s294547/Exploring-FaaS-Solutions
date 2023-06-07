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
3. [feed_action](#feed_action)


## Introduction

This folder contains the code of the OpenWhisk actions that will be created.

You will find some files and folders:
1. [addReadingsToDB.js]: the code of the action that saves the local data in the local InfluxDB instance.
2. [aggregates]: a folder with the code of the actions that compute some aggregates  from local data and sends them to the centralized InfluxDB instance.
3. [feed_action.js]: the feed action of the mqtt package.

## addReadingsToDB


This is a JavaScript function that sends data to an InfluxDB database. It receives and uses some parameters, which are:

- **url**: the url to contact the local InfluxDB. The parameter must have te following format: "http://<influxDBClusterIPServiceName>:<influxDBClusterIpServicePort>"
- **token**: the token of the local influxdb instance.
- **org**: the organization of the local influxDB instance.
- **bucket**: the bucket of the local InfluxDB instance.

## feed_action

This is a NodeJS script that is responsible of creating, deleting and updating OpenWhisk triggers.



