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
	3. [Developing Arduino Project to send data from sensor to IoTHub](#developing-arduino-project-to-send-data-from-sensor-to-IoTHub)
	4. [Create the Azure Function](#create-the-azure-function)
	5. [Send data to Azure CosmosDB MongoDB](#send-data-to-azure-cosmosdb-mongodb)

## Introduction

In this file we will describe how to deliver data from IoT devices to Microsoft Azure Functions. The proposed solution is based on the MQTT protocol. In particular, in this file we will describe how to use an MQTT client to trigger serverless functions. 
In particular, there are some important folders:

1. [Azure_IoT_Hub_ESP8266](./Azure_IoT_Hub_ESP8266/): it contains the arduino project to connect a ESP8266 sensor to a given IoTHub and publish data. 
2. [project](./project/): it contains the C# fuction that is developed as azure function, which is called when data are published on a topic by the sensor.



## How To Build and Trigger an Azure Function from IoT Hub

### Prepare IoT Hub
To connect out IoT device with the IoT Hub, follow this tutorial (https://www.youtube.com/watch?v=nj9laMzjqQ0). 

We have an mqtt client, on the cloud we have both IoT Hub and Azure Functions. Azure IoT Hub is esssentially an MQTT broker, so it means we can trigger this serverless code by publishing a MQTT message from our client to the IoT Hub.

[hub-func](./images/hub-func.png)

At first, we have to create an azure IoT Hub.

Now the next thing is to create an IoT device from the IoT Hub. After having entered in the IoT Hub resource, we must select the section *IoT devices* and then here we will be able to create a new device.

In the section *Message Routing* of the IoT Hub we have to add a route. As endpoint we will choose *events*. To catch the messages published on the MQTT topic, we have to choose as data origin the *Telemetry messages*. We may filter them using the query tool.

### Developing Arduino Project to send data from sensor to IoTHub

I started from the project provided [here](https://github.com/Azure/azure-sdk-for-c-arduino/tree/main/examples/Azure_IoT_Hub_ESP8266). I had to change the parameters in [this file](./Azure_IoT_Hub_ESP8266/iot_configs.h).

### Simulate an IoT Device Sending Data to IoT Hub

In [this link](https://azure-samples.github.io/raspberry-pi-web-simulator/) we can find an useful tool that simulates a raspberry pi sensor which sends data to our IoT Hub. 

### Create the Azure Function

To create the Azure function, we will use VSC. At first, we have to select as function template *Azure Event Hub Trigger*. To find the name of the event hub to which the event will be sent, we need to go back to the IoT Hub on Azure Portal, and we will find it in the *Endpoint* sections, as we can see in the following image:

[event-hub-name](./images/event-hub-name.png)

In the generated file with the C# code ([example](./project/EventHubTrigger1.cs)), we need to fill be sure the *Connection* parameter is equal to *ConnectionString*. Then, in the [*local.settings.json* file](./project/local.settings.json), we must add *ConnectionString* and put it equal to the value of the connection string. This value can be found also in the endpoint section, as we can see in the image:

[endpoint](./images/endpoint.png)

Note: You would need to remove the EntityPath=<Event Hub Instance Name> at the end of the connection string as we already provided that in the function name.

After that, we can deploy the azure function to Function App.

Note: Once the function is deployed you would have to create an application setting parameter to provide Connection string. Please refer the below image to help you add this setting.

[settings](./images/settings.png)


### Send data to Azure CosmosDB MongoDB

[Reference](https://rubenheeren.com/posts/azure-cosmos-db-functions-app-api-exploring-dotnet-e3.html)

At first, I needed to create an *Azure CosmosDB Account*. I created a MongoDB one. 

I kept using the first created project. In the same folder of the function created before, I created a cs file called [Post.cs](./project/Post.cs). 

The provided code is this one:

```
using Newtonsoft.Json;

namespace Company.Function;

internal class Post
{
    [JsonProperty(PropertyName = "id")]
    public string id { get; set; } 

    [JsonProperty(PropertyName = "device_id")]
    public double device_id { get; set; }

    [JsonProperty(PropertyName = "humidity")]
    public double humidity { get; set; }

    [JsonProperty(PropertyName = "temperature")]
    public double temperature { get; set; }

    [JsonProperty(PropertyName = "gas_perc")]
    public double gas_perc { get; set; }

    /*[JsonProperty(PropertyName = "timestamp")]
    public string timestamp { get; set; }*/
}
```

To find the connection string, we need to go in the *Azure CosmosDB Account* resource in the Azure portal. In the *Keys* section, we'll need to copy the *Primary Connection String*. This string will be required soon, when we'll deploy the function to the Azure Portal.

Then I also needed to update the code of the [Event Hub Trigger](./project/EventHubTrigger1.cs).
The following code contains the updated code: 

```
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.CosmosDB;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.WebJobs.Host;

namespace Company.Function
{
    public static class EventHubTrigger1
    {
        [FunctionName("EventHubTrigger1")]
        public static async Task Run([EventHubTrigger("iot-hub-tesi-bianchi", Connection = "ConnectionString")] EventData[] events, [CosmosDB(
            databaseName: "measurments", 
            containerName: "test",
            Connection = "CosmosDbConnectionString",
            CreateIfNotExists = true,
            PartitionKey = "/device_id")]
        IAsyncCollector<dynamic> documentsOut, ILogger log)
        {
            var exceptions = new List<Exception>();

            foreach (EventData eventData in events)
            {
                try
                {
                    // Replace these two lines with your processing logic.
                    log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");
                    
                    dynamic data = Newtonsoft.Json.JsonConvert.DeserializeObject(Encoding.UTF8.GetString(eventData.EventBody.ToArray()));
                    double humidity= data.humidity;
                    double temperature= data.temperature;
                    double gas_perc= data.gas_perc;
                    //string timestamp= data.timestamp;
                    double device_id=data.device;

                    Post postToCreate = new()
                    
                    {
                        // Create a random ID.
                        id = Guid.NewGuid().ToString(),
                        device_id = device_id,
                        humidity = humidity,
                        temperature = temperature,
                        gas_perc= gas_perc
                        //timestamp= timestamp
                    };


                    // Add a JSON document to the output container.
                    await documentsOut.AddAsync(postToCreate);

                    
                    await Task.Yield();
                }
                catch (Exception e)
                {
                    log.LogInformation(e.ToString());
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
    }
}
```

Because we are using an Azure Cosmos DB output binding, we must have the corresponding bindings extension installed before you run the project. To do that, I executed the command:

```
dotnet add package Microsoft.Azure.WebJobs.Extensions.CosmosDB
```

[TO BE COMPLETED FROM NOW ON]