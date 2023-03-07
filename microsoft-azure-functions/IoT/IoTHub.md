# Azure functions + Iot Hub

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [How To Build and Trigger an Azure Function from IoT Hub](#how-to-build-and-trigger-an-azure-function-from-iot-hub)

## Introduction

In this file we will describe how to deliver data from IoT devices to Microsoft Azure Functions. The proposed solution is based on the MQTT protocol. In particular, in this file we will describe how to use an MQTT client to trigger serverless functions. 

## How To Build and Trigger an Azure Function from IoT Hub

To connect out IoT device with the IoT Hub, follow this tutorial (https://www.youtube.com/watch?v=nj9laMzjqQ0). 

We have an mqtt client, on the cloud we have both IoT Hub and Azure Functions. Azure IoT Hub is esssentially an MQTT broker, so it means we can trigger this serverless code by publishing a MQTT message from our client to the IoT Hub.

[hub-func](./hub-func.png)

At first, we have to create an azure IoT Hub.

Now the next thing is to create an IoT device from the IoT Hub. After having entered in the IoT Hub resource, we must select the section *IoT devices* and then here we will be able to create a new device.

We want to start publishing messages from my device to the IoT Hub and we'll need six details:
1. url: ssl://name-of-iot-hub.azure-devices.net
2. port: 8883
3. clientId: name of my device in iot hub
4. username: name-of-iot-hub.azure-devices.net/device-name-in-iot-hub
5. password:
6. devices/nome-dispositivo/messages/events

The password is the authentication token. To generate the auth tolken you must use our IoT Hub connection string. Back to the azure portal, on the page regarding the IoT Hub, on the left side under *Settings* we must enter *Shared access policies*, then we must select *iothubowner* policy and copy the connection string. 

After having done that, we must open the device explorer utility and copy the IoT Hub connection string into it, then we need to press *UPDATE*. We move in the Management tab, click *SAS TOKEN*, click *generate*. Then I copy the *SharedAccessSignature* field anduse it as password.

Where we can find the code related to the MQTT lcient, we must configure it with the parameters we told before. 

Then, we will create an azure function that will be triggered by an MQTT message. To create and azure function event hub trigger follow [this tutorial](https://www.youtube.com/watch?v=7O9jYa_tLHA)