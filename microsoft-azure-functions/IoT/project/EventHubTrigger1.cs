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