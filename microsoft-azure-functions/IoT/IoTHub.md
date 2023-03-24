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
	1. [Prepare IoT Hub](#prepare-iot-hub)
    2. [Simulate an IoT Device Sending Data to IoT Hub](#simulate-an-iot-device-sending-data-to-iot-hub)

## Introduction

In this file we will describe how to deliver data from IoT devices to Microsoft Azure Functions. The proposed solution is based on the MQTT protocol. In particular, in this file we will describe how to use an MQTT client to trigger serverless functions. 

## How To Build and Trigger an Azure Function from IoT Hub

### Prepare IoT Hub
To connect out IoT device with the IoT Hub, follow this tutorial (https://www.youtube.com/watch?v=nj9laMzjqQ0). 

We have an mqtt client, on the cloud we have both IoT Hub and Azure Functions. Azure IoT Hub is esssentially an MQTT broker, so it means we can trigger this serverless code by publishing a MQTT message from our client to the IoT Hub.

[hub-func](./hub-func.png)

At first, we have to create an azure IoT Hub.

Now the next thing is to create an IoT device from the IoT Hub. After having entered in the IoT Hub resource, we must select the section *IoT devices* and then here we will be able to create a new device.

In the section *Message Routing* of the IoT Hub we have to add a route. As endpoint we will choose *events*. To catch the messages published on the MQTT topic, we have to choose as data origin the *Telemetry messages*. We may filter them using the query tool.

### Simulate an IoT Device Sending Data to IoT Hub

In [this link](https://azure-samples.github.io/raspberry-pi-web-simulator/) we can find an useful tool that simulates a raspberry pi sensor which sends data to our IoT Hub. 

### Create the Azure Function

To create the Azure function, we will use VSC. At first, we have to select as function template *Azure Event Hub Trigger*. To find the name of the event hub to which the event will be sent, we need to go back to the IoT Hub on Azure Portal, and we will find it in the *Endpoint* sections, as we can see in the following image:

[event-hub-name](./event-hub-name.png)

In the generated file with the C# code ([example](./project/EventHubTrigger1.cs)), we need to fill be sure the *Connection* parameter is equal to *ConnectionString*. Then, in the [*local.settings.json* file](./project/local.settings.json), we must add *ConnectionString* and put it equal to the value of the connection string. This value can be found also in the endpoint section, as we can see in the image:

[endpoint](./endpoint.png)

Note: You would need to remove the EntityPath=<Event Hub Instance Name> at the end of the connection string as we already provided that in the function name.

After that, we can deploy the azure function to Function App.

Note: Once the function is deployed you would have to create an application setting parameter to provide Connection string. Please refer the below image to help you add this setting.

[settings](./settings.png)