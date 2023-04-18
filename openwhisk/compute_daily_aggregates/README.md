# DATA ACQUISITION AND AGGREGATION

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Creating the Action](#creating-the-action)
3. [Creating the trigger](#creating-the-trigger)


## Introduction
In this file I am going to show all the steps required to send data from a sensor to the local instance of InfluxDB. I will also set up a daily trigger that computes some aggregate values and sends them to a centralized database instance.

## Creating the action

At first, we need to create an action that gets the daily data from the local Influxdb instance, computes the aggregates and then sends them to the centralized InfluxDB instance. All the informations related to how to access the database are passed as parameters. We can find the action code in [aggregatesAction.js](./aggregatesAction.js).

After having tested the action locally, we need to deploy it.

```
wsk -i action create aggregatesAction  aggregatesAction.js
```

## Creating the Trigger

We will create a trigger that is fired at 3:00 every day and computes some aggregates. Then, the aggregates are all sent to a remote DB, and they will be stored according to the name of the data center which they were computed. 

```
wsk trigger create aggregatesTrigger --feed /whisk.system/alarms/alarm --param cron "0 3 * * *" --param trigger_payload "{\"local_url\":\"https://influxdb-gateway.liquidfaas.cloud\",\"local_token\":\"ZwWM2Gx17aMnJrBSIvbec1WK0Xga1oCJ\",\"local_org\":\"influxdata\",\"local_bucket\":\"measure\",\"central_url\":\"https://influxdb-centralized-gateway.liquidfaas.cloud\",\"central_token\":\"zXURcTp7ZcGr4n8p3RUbLadBfUWK7rH7\",\"central_org\":\"influxdata\",\"central_bucket\":\"measure\",\"location\":\"test_office\"}" -i
```

Then, I must bind the trigger to the action:

```
wsk rule create aggregatesRule aggregatesTrigger aggregatesAction -i
``` 





