# MICROSOFT AZURE FUNCTIONS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Microsoft Azure](#microsoft-azure)
	1. [Overview](#overview)
	2. [Microsoft Azure Services](#microsoft-azure-services)
	3. [Azure account](#azure-account)
3. [Azure Functions](#azure-functions)
	1. [Azure Durable Functions](#azure-durable-functions)
	2. [Compare Azure Functions hosting options](#compare-azure-functions-hosting-options)
	3. [Scale Azure Functions](#scale-azure-functions)
	4. [Explore Azure Functions development](#explore-azure-functions-development)
	5. [Create trigger and bindings](#create-trigger-and-bindings)
	6. [Connect functions to Azure services](#connect-functions-to-azure-services)
	7. [Azure Functions and IoT](#azure-functions-and-iot)
4. [Create an Azure Function with VSC](#create-an-azure-function-with-VSC)
	1. [Prerequisites](#prerequisites)
	2. [Create your local project](#create-your-local-project)
	3. [Run the function locally](#run-the function-locally)
	4. [Sign in to Azure](#sign-in-to-azure)
	5. [Run the function locally](#run-the-function-locally)
	6. [Create resources in Azure](#create-resources-in-azure)
	7. [ Deploy the code ](#deploy-the-code)
	8. [Run the function in Azure](#Run-the-function-in-azure)
	9. [Connect to storage](#connect-to-storage)
	10. [Delete a Function](#delete-a-function)
4. [Monitor executions in Azure Functions](#monitor-executions-in-azure-functions)
5. [Add on](#add-on)
	1. [Event Hubs and IoT Hub Triggers](#event-hubs-and-iot-hub-triggers) 
	2. [EventProcessorHost](#eventprocessorhost)  
	3. [Resource Group](#resource-group)  
	4. [Azure Storage Account](#azure-storage-account)  
	5. [Function App](#function-app)  
	6. [Azure Application Insights](#azure-application-insights) 
	6. [Azure Monitor](#azure-monitor)

## Introduction

This file will contain all the retrieved informations about Microsoft Azure and, in particular, about microsoft azure functions. 

## Microsoft Azure

### Overview

Azure is a cloud computing platform with an ever-expanding set of services to help you build solutions to meet your business goals. Azure services range from simple web services for hosting your business presence in the cloud to running fully virtualized computers for you to run your custom software solutions. Azure provides a wealth of cloud-based services like remote storage, database hosting, and centralized account management. Azure also offers new capabilities like AI and Internet of Things (IoT). [1](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-fundamentals/introduction).

Azure is a continually expanding set of cloud services that help your organization meet your current and future business challenges. Azure gives you the freedom to build, manage, and deploy applications on a massive global network using your favorite tools and frameworks.

**What does Azure offer?**
With help from Azure, you have everything you need to build your next great solution. The following table lists several of the benefits that Azure provides, so you can easily invent with purpose.
1. Be ready for the future: Continuous innovation from Microsoft supports your development today and your product visions for tomorrow.
2. Build on your terms: You have choices. With a commitment to open source, and support for all languages and frameworks, you can build how you want and deploy where you want to.
3. Operate hybrid seamlessly: On-premises, in the cloud, and at the edge--we'll meet you where you are. Integrate and manage your environments with tools and services designed for a hybrid cloud solution.
4. Trust your cloud: Get security from the ground up, backed by a team of experts, and proactive compliance trusted by enterprises, governments, and startups.

**What can I do with Azure?**
Azure provides more than 100 services that enable you to do everything from running your existing applications on virtual machines, to exploring new software paradigms, such as intelligent bots and mixed reality.
Many teams start exploring the cloud by moving their existing applications to virtual machines that run in Azure. Migrating your existing apps to virtual machines is a good start, but the cloud is much more than a different place to run your virtual machines.
For example, Azure provides AI and machine-learning services that can naturally communicate with your users through vision, hearing, and speech. It also provides storage solutions that dynamically grow to accommodate massive amounts of data. Azure services enable solutions that aren't feasible without the power of the cloud.

**How does Azure work?**
Azure uses a tchnology known as virtualization, which separates the thight coupling between the computer's hardware and its operating system, using an abstraction layer called *hypervisor*. An hypervisor emulates all the functions of a real computer and its CPU on a virtual machine. It can run multiple virtual machine at the same time, and each virtual machine can run any compatible operating system. 
Azure takes this virtualization technology and repeats it on a massive scale, in Microsoft data centers throughout the world. Each data center has mini-racks filled with servers and each server has an hypervisor to run multiple virtual machines.
A network switch provides connectivity to all those servers. One server on each rack has a special piece of software called fabric controller. Each fabric controller is connected to another special piece of software known as the *orchestrator*. The orchestrator is responsible for managing everything that happens in azure, including responding to user requests.
Users make requests using the Orchestrator's Web API. The Web API can be called by many tools, including the user interface of the Azure portal. When a user makes a request to create a VM, the rochestrator packages everything that is needed, the orchestrator picks the best rack and send the package and the request to the fabric controller. Once the fabric controller has created the virtual machine, the user can connect to it. [2](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-fundamentals/what-is-microsoft-azure)

**What is the Azure portal**
The Azure portal is a web-based, unified console that provides an alternative to command-line tools. With the Azure portal, you can manage your Azure subscription by using a graphical user interface. You can:
1. Build, manage, and monitor everything from simple web apps to complex cloud deployments.
2. Create custom dashboards for an organized view of resources.
3. Configure accessibility options for an optimal experience.
The Azure portal is designed for resiliency and continuous availability. It maintains a presence in every Azure datacenter. This configuration makes the Azure portal resilient to individual datacenter failures and avoids network slowdowns by being close to users. The Azure portal updates continuously and requires no downtime for maintenance activities.

[azure-portal](./azure-portal.png)

### Microsoft Azure Services

Microsoft Azure has a lot of different services. We can divide them in ten categories:
1. Compute: these cloud services let you scale your computing capability on demand, only paying what you use. You can add virtual machines as needed or scale you company app's services for web and mobile apps.
Examples:

1. *Azure Virtual Machines*: Windows or Linux virtual machines (VMs) hosted in Azure.
2. *Azure Virtual Machine Scale Sets*: Scaling for Windows or Linux VMs hosted in Azure.
3. *Azure Kubernetes Service*: Cluster management for VMs that run containerized services.
4. *Azure Service Fabric*: Distributed systems platform that runs in Azure or on-premises.
5. *Azure Batch*: Managed service for parallel and high-performance computing applications.
6. *Azure Container Instances*: Containerized apps run on Azure without provisioning servers or VMs.
7. *Azure Functions*: An event-driven, serverless compute service.
2. Networking: these features let you connect your Cloud and on-premise infrastructure in order to bring the best possible experience to your customers. VPNs and load balancing are two examples of these features.
Examples:

1. *Azure Virtual Network*: Connects VMs to incoming virtual private network (VPN) connections.
2. *Azure Load Balancer*: Balances inbound and outbound connections to applications or service endpoints.
3. *Azure Application Gateway*: Optimizes app server farm delivery while increasing application security.
4. *Azure VPN Gateway*: Accesses Azure Virtual Networks through high-performance VPN gateways.
5. *Azure DNS*: Provides ultra-fast DNS responses and ultra-high domain availability.
6. *Azure Content Delivery Network*: Delivers high-bandwidth content to customers globally.
7. *Azure DDoS Protection*: Protects Azure-hosted applications from distributed denial of service (DDOS) attacks.
8. *Azure Traffic Manager*: Distributes network traffic across Azure regions worldwide.
9. *Azure ExpressRoute*: Connects to Azure over high-bandwidth dedicated secure connections.
10. *Azure Network Watcher*: Monitors and diagnoses network issues by using scenario-based analysis.
11. *Azure Firewall*: Implements high-security, high-availability firewall with unlimited scalability.
12. *Azure Virtual WAN*: Creates a unified wide area network (WAN) that connects local and remote sites.

3. Storage: these services let you scale your data and app storage needs in a secured way.
Examples:

1. *Azure Blob storage*: Storage service for very large objects, such as video files or bitmaps.
2. *Azure File storage*: File shares that can be accessed and managed like a file server.
3. *Azure Queue storage*: A data store for queuing and reliably delivering messages between applications.
4. *Azure Table storage*: Table storage is a service that stores non-relational structured data (also known as structured NoSQL data) in the cloud, providing a key/attribute store with a schemaless design.

4. Mobile: you can build and deploy cross-platform and native apps for any mobile device. You can also take advantage of cognitive services to make your apps smarter.

5. Databases: choose from a variety of proprietary or oper-source engines to bring your current databases to the cloud. Use tools to manage your SQL, like CosmosDB, MySQL and other data services.
Example:

1. *Azure Cosmos DB*: Globally distributed database that supports NoSQL options.
2. *Azure SQL Database*: Fully managed relational database with auto-scale, integral intelligence, and robust security.
3. *Azure Database for MySQL*: Fully managed and scalable MySQL relational database with high availability and security.
4. *Azure Database for PostgreSQL*: Fully managed and scalable PostgreSQL relational database with high availability and security.
5. *SQL Server on Azure Virtual Machines*: Service that hosts enterprise SQL Server apps in the cloud.
6. *Azure Synapse Analytics*: Fully managed data warehouse with integral security at every level of scale at no extra cost.
7. *Azure Database Migration Service*: Service that migrates databases to the cloud with no application code changes.
8. *Azure Cache for Redis*: Fully managed service caches frequently used and static data to reduce data and application latency.
9. *Azure Database for MariaDB*: Fully managed and scalable MariaDB relational database with high availability and security.

6. Web: thee services help you build, deploy, manage and scale your web application. You can create web apps, publish APIs to your services or use Azure Maps.
Examples:

1. *Azure App Service*: Quickly create powerful cloud web-based apps.
2. *Azure Notification Hubs*: Send push notifications to any platform from any back end.
3. *Azure API Management*: Publish APIs to developers, partners, and employees securely and at scale.
4. *Azure Cognitive Search*: Deploy this fully managed search as a service.
5. *Web Apps feature of Azure App Service*: Create and deploy mission-critical web apps at scale.
6. *Azure SignalR Service*: Add real-time web functionalities easily.

7. IoT: use these features to connect, monitor and manage all of your IoT assets. Analyze the data as it arrives from sensors, and take meaningful acgtion with it.
Examples:

1. *IoT Central*: Fully managed global IoT software as a service (SaaS) solution that makes it easy to connect, monitor, and manage IoT assets at scale.
2. *Azure IoT Hub*: Messaging hub that provides secure communications between and monitoring of millions of IoT devices.
3. *IoT Edge*: Fully managed service that allows data analysis models to be pushed directly onto IoT devices, which allows them to react quickly to state changes without needing to consult cloud-based AI models.

8. Big Data: when you have large volumes of data, these open-source cluster services will help you run analytics at a massive scale and make decisions based off of complex queries. 
Examples:

1. *Azure Synapse Analytics*: Run analytics at a massive scale by using a cloud-based enterprise data warehouse that takes advantage of massively parallel processing to run complex queries quickly across petabytes of data.
2. *Azure HDInsight*: Process massive amounts of data with managed clusters of Hadoop clusters in the cloud.
3. *Azure Databricks*: Integrate this collaborative Apache Spark-based analytics service with other big data services in Azure.

9. AI: use you existing data to forecast future behaviors based on these AI services. Use machine learning to build, train and deploy models to the cloud.
Examples:

1. *Azure Machine Learning Service*: Cloud-based environment you can use to develop, train, test, deploy, manage, and track machine learning models. It can auto-generate a model and auto-tune it for you. It will let you start training on your local machine, and then scale out to the cloud.
2. *Azure ML Studio*: Collaborative visual workspace where you can build, test, and deploy machine learning solutions by using prebuilt machine learning algorithms and data-handling modules.

10. DevOps: it bringstogether people, processes, and technology to automate software delkivery to procide continuous value to your users. You can create, build and release pipelines that provide continuous integration, delivery and deployment for your applications.
Examples:

1. *Azure DevOps*: Use development collaboration tools such as high-performance pipelines, free private Git repositories, configurable Kanban boards, and extensive automated and cloud-based load testing. Formerly known as Visual Studio Team Services.
2. *Azure DevTest Labs*: Quickly create on-demand Windows and Linux environments to test or demo applications directly from deployment pipelines.

[3](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-fundamentals/tour-of-azure-services)

[azure-services](./azure-services.png)

### Azure Account

To create and use Azure services, you need an Azure subscription. When you're working with your own applications and business needs, you need to create an Azure account, and a subscription will be created for you. After you've created an Azure account, you're free to create additional subscriptions. For example, your company might use a single Azure account for your business and separate subscriptions for development, marketing, and sales departments. After you've created an Azure subscription, you can start creating Azure resources within each subscription.
In any subscription, you can create resource groups, which contain a set of resources. 

[4](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-fundamentals/get-started-with-azure-accounts)
[azure-accounts](./azure-account.png)

## Azure Functions 

Azure Functions are a great solution for processing data, integrating systems, working with the internet-of-things (IoT), and building simple APIs and microservices. Consider Functions for tasks like image or order processing, file maintenance, or for any tasks that you want to run on a schedule. Functions provides templates to get you started with key scenarios.

Azure Functions supports triggers, which are ways to start execution of your code, and bindings, which are ways to simplify coding for input and output data. There are other integration and automation services in Azure and they all can solve integration problems and automate business processes. They can all define input, actions, conditions, and output.

### Azure Durable Functions

Durable Functions is an extension of Azure Functions that lets you write stateful functions in a serverless compute environment. The extension lets you define stateful workflows by writing orchestrator functions and stateful entities by writing entity functions using the Azure Functions programming model. Behind the scenes, the extension manages state, checkpoints, and restarts for you, allowing you to focus on your business logic.

### Compare Azure Functions hosting options

When you create a function app in Azure, you must choose a hosting plan for your app. There are three basic hosting plans available for Azure Functions: Consumption plan, Functions Premium plan, and App service (Dedicated) plan. All hosting plans are generally available (GA) on both Linux and Windows virtual machines.

The hosting plan you choose dictates the following behaviors:
1. How your function app is scaled.
2. The resources available to each function app instance.
3. Support for advanced functionality, such as Azure Virtual Network connectivity.

The following is a summary of the benefits of the three main hosting plans for Functions:

1. *Consumption plan*:	This is the default hosting plan. It scales automatically and you only pay for compute resources when your functions are running. Instances of the Functions host are dynamically added and removed based on the number of incoming events.
2. *Premium plan*:	Automatically scales based on demand using pre-warmed workers, which run applications with no delay after being idle, runs on more powerful instances, and connects to virtual networks.
3. *Dedicated plan*:	Run your functions within an App Service plan at regular App Service plan rates. Best for long-running scenarios where Durable Functions can't be used.

There are two other hosting options, which provide the highest amount of control and isolation in which to run your function apps:

1. *ASE*:	App Service Environment (ASE) is an App Service feature that provides a fully isolated and dedicated environment for securely running App Service apps at high scale.
2. *Kubernetes*:	Kubernetes provides a fully isolated and dedicated environment running on top of the Kubernetes platform. For more information visit Azure Functions on Kubernetes with KEDA.

**Always on**
If you run on a Dedicated plan, you should enable the Always on setting so that your function app runs correctly. On an App Service plan, the functions runtime goes idle after a few minutes of inactivity, so only HTTP triggers will "wake up" your functions. Always on is available only on an App Service plan. On a Consumption plan, the platform activates function apps automatically.

**Storage account requirements**
On any plan, a function app requires a general Azure Storage account, which supports Azure Blob, Queue, Files, and Table storage. This is because Functions rely on Azure Storage for operations such as managing triggers and logging function executions, but some storage accounts don't support queues and tables. These accounts, which include blob-only storage accounts (including premium storage) and general-purpose storage accounts with zone-redundant storage replication, are filtered-out from your existing Storage Account selections when you create a function app.

The same storage account used by your function app can also be used by your triggers and bindings to store your application data. However, for storage-intensive operations, you should use a separate storage account.

[5](https://learn.microsoft.com/en-us/training/modules/explore-azure-functions/3-compare-azure-functions-hosting-options)

### Scale Azure Functions

In the Consumption and Premium plans, Azure Functions scales CPU and memory resources by adding additional instances of the Functions host. The number of instances is determined on the number of events that trigger a function.

Each instance of the Functions host (the set of resources needed to run your functions) in the Consumption plan is limited to 1.5 GB of memory and one CPU. An instance of the host is the entire function app, meaning all functions within a function app share resource within an instance and scale at the same time. Function apps that share the same Consumption plan scale independently. In the Premium plan, the plan size determines the available memory and CPU for all apps in that plan on that instance.

Function code files (Function code files are the actual code files that contain the logic for your Azure Functions) are stored on Azure Files shares on the function's main storage account. When you delete the main storage account of the function app, the function code files are deleted and cannot be recovered. This means that if you need to keep a copy of your code files for backup or archival purposes, you should make sure to keep a separate copy outside of your Azure Functions app, such as in a version control system like Git.

**Runtime scaling**
Azure Functions uses a component called the **scale controller** to monitor the rate of events and determine whether to scale out or scale in. The scale controller uses heuristics for each trigger type. For example, when you're using an Azure Queue storage trigger, it scales based on the queue length and the age of the oldest queue message.

The unit of scale for Azure Functions is the function app. When the function app is scaled out, additional resources are allocated to run multiple instances of the Azure Functions host. Conversely, as compute demand is reduced, the scale controller removes function host instances. The number of instances is eventually "scaled in" to zero when no functions are running within a function app.

[scale-controller](./scale-controller.png)

**Cold Start**

After your function app has been idle for a number of minutes, the platform may scale the number of instances on which your app runs down to zero. The next request has the added latency of scaling from zero to one. This latency is referred to as a cold start. The number of dependencies required by your function app can affect the cold start time. Cold start is more of an issue for synchronous operations, such as HTTP triggers that must return a response. If cold starts are impacting your functions, consider running in a Premium plan or in a Dedicated plan with the Always on setting enabled.

[reference](https://learn.microsoft.com/en-us/azure/azure-functions/event-driven-scaling)

**Scaling behaviors**

Scaling can vary on a number of factors, and scale differently based on the trigger and language selected. There are a few intricacies of scaling behaviors to be aware of:

*Maximum instances*: A single function app only scales out to a maximum of 200 instances. A single instance may process more than one message or request at a time though, so there isn't a set limit on number of concurrent executions.
*New instance rate*: For HTTP triggers, new instances are allocated, at most, once per second. For non-HTTP triggers, new instances are allocated, at most, once every 30 seconds.

**Limit scale out**

You may wish to restrict the maximum number of instances an app used to scale out. This is most common for cases where a downstream component like a database has limited throughput. By default, Consumption plan functions scale out to as many as 200 instances, and Premium plan functions will scale out to as many as 100 instances. You can specify a lower maximum for a specific app by modifying the *functionAppScaleLimit* value. The *functionAppScaleLimit* can be set to 0 or null for unrestricted, or a valid value between 1 and the app maximum.

**Scale-in behaviors**
Event-driven scaling automatically reduces capacity when demand for your functions is reduced. It does this by shutting down worker instances of your function app. Before an instance is shut down, new events stop being sent to the instance. Also, functions that are currently executing are given time to finish executing. This behavior is logged as drain mode. This shut-down period can extend up to 10 minutes for Consumption plan apps and up to 60 minutes for Premium plan apps. Event-driven scaling and this behavior don't apply to Dedicated plan apps.

The following considerations apply for scale-in behaviors:

For Consumption plan function apps running on Windows, only apps created after May 2021 have drain mode behaviors enabled by default.
To enable graceful shutdown for functions using the Service Bus trigger, use version 4.2.0 or a later version of the Service Bus Extension.

**Event Hubs triggers**
This section describes how scaling behaves when your function uses an [*Event Hubs trigger* or an *IoT Hub trigger*](#event-hubs-and-iot-hub-triggers). In these cases, each instance of an event triggered function is backed by a single *EventProcessorHost* instance. The trigger (powered by Event Hubs) ensures that only one [*EventProcessorHost*](#eventprocessorhost) instance can get a lease on a given partition.

For example, consider an event hub as follows:

10 partitions
1,000 events distributed evenly across all partitions, with 100 messages in each partition

When your function is first enabled, there's only one instance of the function. Let's call the first function instance *Function_0*. The *Function_0* function has a single instance of *EventProcessorHost* that holds a lease on all 10 partitions. This instance is reading events from partitions 0-9. From this point forward, one of the following happens:

1. New function instances are not needed: *Function_0* is able to process all 1,000 events before the Functions scaling logic take effect. In this case, all 1,000 messages are processed by *Function_0*.
2. An additional function instance is added: If the Functions scaling logic determines that *Function_0* has more messages than it can process, a new function app instance (*Function_1*) is created. This new function also has an associated instance of EventProcessorHost. As the underlying event hub detects that a new host instance is trying read messages, it load balances the partitions across the host instances. For example, partitions 0-4 may be assigned to *Function_0* and partitions 5-9 to *Function_1*.

3. N more function instances are added: If the Functions scaling logic determines that both *Function_0* and *Function_1* have more messages than they can process, new *Functions_N* function app instances are created. Apps are created to the point where N is greater than the number of event hub partitions. In our example, Event Hubs again load balances the partitions, in this case across the instances *Function_0*...*Functions_9*.

As scaling occurs, N instances is a number greater than the number of event hub partitions. This pattern is used to ensure *EventProcessorHost* instances are available to obtain locks on partitions as they become available from other instances. You're only charged for the resources used when the function instance executes. In other words, you aren't charged for this over-provisioning.

When all function execution completes (with or without errors), checkpoints are added to the associated storage account. When check-pointing succeeds, all 1,000 messages are never retrieved again.

[reference](https://learn.microsoft.com/en-us/azure/azure-functions/event-driven-scaling)

**Azure Functions scaling in an App service plan**

Using an App Service plan, you can manually scale out by adding more VM instances. You can also enable autoscale, though autoscale will be slower than the elastic scale of the Premium plan.

[6](https://learn.microsoft.com/en-us/training/modules/explore-azure-functions/4-scale-azure-functions)

### Explore Azure Functions development

A function contains two important pieces - your code, which can be written in a variety of languages, and some config, the function.json file. For compiled languages, this config file is generated automatically from annotations in your code. For scripting languages, you must provide the config file yourself.

The *function.json* file defines the function's trigger, bindings, and other configuration settings. Every function has one and only one trigger. The runtime uses this config file to determine the events to monitor and how to pass data into and return data from a function execution. The following is an example function.json file.


```
{
    "disabled":false,
    "bindings":[
        // ... bindings here
        {
            "type": "bindingType",
            "direction": "in",
            "name": "myParamName",
            // ... more depending on binding
        }
    ]
}
```
The bindings property is where you configure both triggers (a specific event that initiates the execution of a serverless function) and bindings (a way of defining the input and output parameters of a function and mapping them to external resources). Each binding shares a few common settings and some settings which are specific to a particular type of binding. Every binding requires the following settings:

|**Property**|**Type**|**Comments**|
|:----------: |:----------: |:----------: |
|type| string|Name of binding. For example, queueTrigger.|
|direction|	string|	Indicates whether the binding is for receiving data into the function or sending data from the function. For example, in or out.|
|name|string|	The name that is used for the bound data in the function. For example, myQueue.|

**Function app**
A function app provides an execution context in Azure in which your functions run. As such, it is the unit of deployment and management for your functions. A function app is composed of one or more individual functions that are managed, deployed, and scaled together. All of the functions in a function app share the same pricing plan, deployment method, and runtime version. Think of a function app as a way to organize and collectively manage your functions.

In Functions 2.x all functions in a function app must be authored in the same language. In previous versions of the Azure Functions runtime, this wasn't required.

**Folder structure**
The code for all the functions in a specific function app is located in a root project folder that contains a host configuration file. The host.json file contains runtime-specific configurations and is in the root folder of the function app. A bin folder contains packages and other library files that the function app requires. Specific folder structures required by the function app depend on language.

**Local development environments**
Functions makes it easy to use your favorite code editor and development tools to create and test functions on your local computer. Your local functions can connect to live Azure services, and you can debug them on your local computer using the full Functions runtime.

[7](https://learn.microsoft.com/en-us/training/modules/develop-azure-functions/2-azure-function-development-overview)

### Create trigger and bindings

Triggers are what cause a function to run. A trigger defines how a function is invoked and a function must have exactly one trigger. Triggers have associated data, which is often provided as the payload of the function.

Binding to a function is a way of declaratively connecting another resource to the function; bindings may be connected as input bindings, output bindings, or both. Data from bindings is provided to the function as parameters.

You can mix and match different bindings to suit your needs. Bindings are optional and a function might have one or multiple input and/or output bindings.

Triggers and bindings let you avoid hardcoding access to other services. Your function receives data (for example, the content of a queue message) in function parameters. You send data (for example, to create a queue message) by using the return value of the function.

**Trigger and binding definitions**
Triggers and bindings are defined differently depending on the development language.

|Language	|Triggers and bindings are configured by...|
|:--------:|:-------------------------------------:|
|C# class library|	decorating methods and parameters with C# attributes|
|Java	|decorating methods and parameters with Java annotations|
|JavaScript/PowerShell/Python/TypeScript	|updating function.json schema|

For languages that rely on *function.json*, the portal provides a UI for adding bindings in the Integration tab. You can also edit the file directly in the portal in the Code + test tab of your function.

In .NET and Java, the parameter type defines the data type for input data. For instance, use string to bind to the text of a queue trigger, a byte array to read as binary, and a custom type to de-serialize to an object. Since .NET class library functions and Java functions don't rely on function.json for binding definitions, they can't be created and edited in the portal. C# portal editing is based on C# script, which uses function.json instead of attributes.

For languages that are dynamically typed such as JavaScript, use the *dataType* property in the function.json file. For example, to read the content of an HTTP request in binary format, set *dataType* to binary:

```
{
    "dataType": "binary",
    "type": "httpTrigger",
    "name": "req",
    "direction": "in"
}
```
Other options for *dataType* are *stream* and *string*.

**Binding direction**
All triggers and bindings have a direction property in the function.json file:
- For triggers, the direction is always in
- Input and output bindings use in and out
- Some bindings support a special direction inout. If you use inout, only the Advanced editor is available via the Integrate tab in the portal.

When you use attributes in a class library to configure triggers and bindings, the direction is provided in an attribute constructor or inferred from the parameter type.

**Azure Functions trigger and binding example**
Suppose you want to write a new row to Azure Table storage whenever a new message appears in Azure Queue storage. This scenario can be implemented using an Azure Queue storage trigger and an Azure Table storage output binding.

Here's a function.json file for this scenario.

```
{
  "bindings": [
    {
      "type": "queueTrigger",
      "direction": "in",
      "name": "order",
      "queueName": "myqueue-items",
      "connection": "MY_STORAGE_ACCT_APP_SETTING"
    },
    {
      "type": "table",
      "direction": "out",
      "name": "$return",
      "tableName": "outTable",
      "connection": "MY_TABLE_STORAGE_ACCT_APP_SETTING"
    }
  ]
}
```
The first element in the bindings array is the Queue storage trigger. The *type* and *direction* properties identify the trigger. The *name* property identifies the function parameter that receives the queue message content. The name of the queue to monitor is in queueName, and the connection string is in the app setting identified by connection.

The second element in the bindings array is the Azure Table Storage output binding. The *type* and *direction* properties identify the binding. The *name* property specifies how the function provides the new table row, in this case by using the function return value. The name of the table is in *tableNameé, and the *connection* string is in the app setting identified by connection.

**C# script example**
Here's C# script code that works with this trigger and binding. Notice that the name of the parameter that provides the queue message content is order; this name is required because the name property value in function.json is order.

```
#r "Newtonsoft.Json"

using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

// From an incoming queue message that is a JSON object, add fields and write to Table storage
// The method return value creates a new row in Table Storage
public static Person Run(JObject order, ILogger log)
{
    return new Person() { 
            PartitionKey = "Orders", 
            RowKey = Guid.NewGuid().ToString(),  
            Name = order["Name"].ToString(),
            MobileNumber = order["MobileNumber"].ToString() };  
}

public class Person
{
    public string PartitionKey { get; set; }
    public string RowKey { get; set; }
    public string Name { get; set; }
    public string MobileNumber { get; set; }
}
JavaScript example
The same function.json file can be used with a JavaScript function:

JavaScript

Copy
// From an incoming queue message that is a JSON object, add fields and write to Table Storage
module.exports = async function (context, order) {
    order.PartitionKey = "Orders";
    order.RowKey = generateRandomId(); 

    context.bindings.order = order;
};

function generateRandomId() {
    return Math.random().toString(36).substring(2, 15) +
        Math.random().toString(36).substring(2, 15);
}
Class library example
In a class library, the same trigger and binding information — queue and table names, storage accounts, function parameters for input and output — is provided by attributes instead of a function.json file. Here's an example:

C#

Copy
public static class QueueTriggerTableOutput
{
    [FunctionName("QueueTriggerTableOutput")]
    [return: Table("outTable", Connection = "MY_TABLE_STORAGE_ACCT_APP_SETTING")]
    public static Person Run(
        [QueueTrigger("myqueue-items", Connection = "MY_STORAGE_ACCT_APP_SETTING")]JObject order,
        ILogger log)
    {
        return new Person() {
                PartitionKey = "Orders",
                RowKey = Guid.NewGuid().ToString(),
                Name = order["Name"].ToString(),
                MobileNumber = order["MobileNumber"].ToString() };
    }
}

public class Person
{
    public string PartitionKey { get; set; }
    public string RowKey { get; set; }
    public string Name { get; set; }
    public string MobileNumber { get; set; }
}
```
[8] https://learn.microsoft.com/en-us/training/modules/develop-azure-functions/3-create-triggers-bindings

### Connect functions to Azure services
Your function project references connection information by name from its configuration provider. It does not directly accept the connection details, allowing them to be changed across environments. For example, a trigger definition might include a connection property. This might refer to a connection string, but you cannot set the connection string directly in a function.json. Instead, you would set connection to the name of an environment variable that contains the connection string.

The default configuration provider uses environment variables. These might be set by Application Settings when running in the Azure Functions service, or from the local settings file when developing locally.

**Connection values**
When the connection name resolves to a single exact value, the runtime identifies the value as a connection string, which typically includes a secret. The details of a connection string are defined by the service to which you wish to connect.

However, a connection name can also refer to a collection of multiple configuration items. Environment variables can be treated as a collection by using a shared prefix that ends in double underscores __. The group can then be referenced by setting the connection name to this prefix.

For example, the connection property for an Azure Blob trigger definition might be Storage1. As long as there is no single string value configured with Storage1 as its name, Storage1__serviceUri would be used for the serviceUri property of the connection. The connection properties are different for each service.

**Configure an identity-based connection**
Some connections in Azure Functions are configured to use an identity instead of a secret. Support depends on the extension using the connection. In some cases, a connection string may still be required in Functions even though the service to which you are connecting supports identity-based connections.

When hosted in the Azure Functions service, identity-based connections use a managed identity. The system-assigned identity is used by default, although a user-assigned identity can be specified with the credential and clientID properties. When run in other contexts, such as local development, your developer identity is used instead, although this can be customized using alternative connection parameters.

**Grant permission to the identity**
Whatever identity is being used must have permissions to perform the intended actions. This is typically done by assigning a role in Azure RBAC or specifying the identity in an access policy, depending on the service to which you are connecting.

[9](https://learn.microsoft.com/en-us/training/modules/develop-azure-functions/4-connect-azure-services)
[9.1](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp)

### Azure Functions and IoT

Here, we'll discuss how you can decide whether Azure Functions is the right choice for your IoT solutions. We'll list some criteria that indicate whether Azure functions will meet your deployment goals for IoT solutions.

Using the serverless computing approach, you can focus on the core logic of your solutions. You avoid the need to manage the underlying infrastructure that runs your solution. In the serverless application model, the cloud service provider automatically provisions, scales, and manages the underlying infrastructure required to run the code. The serverless model has two aspects: function as a service and backend as a service.

Developers write the application as functions. Typically, these functions are stateless and short-lived. Azure functions enable you to chain your functions to create the complete solution. Hence, as a developer, you're concerned with writing functions that interact with each other to solve the business problem. On the other hand, the cloud service provider manages these deployed functions from the perspective of resources like processors, storage, and bandwidth (backend as a service). The resources are provided on an ‘as-needed’ basis and scaled as required. You (the developer) are charged for the function only when the function is actually running (function as service). IoT applications suit many of these characteristics. In the case of IoT applications, you can create a larger application by amalgamating / chaining many functions and scaling them dynamically as needed.

You should consider using Azure Functions for IoT solutions based on the following criteria.

**Business considerations**
The key business considerations for using Azure function for IoT are to create scalable applications where you're charged only for the resources you use. Your solution can scale up or down dynamically and instantly depending on the business requirements. You don't have to manage the infrastructure and to allocate the resources in advance. Other business criteria include faster time to market, the flexibility to use multiple programming languages.

**Considerations for IoT**
Internet of Things solutions are typically event driven that is, you need to define a specific trigger that causes the function to run. If your IoT solution could potentially scale from a small number of devices to millions of devices – you should consider Azure Functions. Similarly, if your solution could see spikes of events to millions of events, you should consider Azure functions.

**Best practice guidelines for Azure Functions**
You should follow the guidelines in using Azure functions.

1. *Avoid long running functions*: Large, long-running functions can cause unexpected timeout issues.
2. *Write functions to be stateless*: Functions should be stateless and idempotent if possible. Idempotence is the property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application. For example, the number 1 is idempotent with respect to the multiplication operation because 1 x 1 = 1. Associate any required state information with your data. It's possible to achieve cross function communication using Durable Functions and Azure Logic Apps that manage state transitions and communication between multiple functions.
3. *Write defensive functions*: Design your functions with the ability to continue from a previous fail point during the next execution.
4. *Scalability best practices*: Share and manage connections, avoid sharing storage accounts, manage function memory usage

[reference](https://learn.microsoft.com/en-us/training/modules/intro-azure-functions-iot/3-how)

## Create an Azure Function with VSC
Here will be reported the steps to create a simple C# function that responds to HTTP requests. After creating and testing the code locally in Visual Studio Code you will deploy to Azure.

### **Prerequisites**
Before you begin make sure you have the following requirements in place:

1. An Azure account with an active subscription. 
2. The Azure Functions Core Tools version 4.x.[10] (https://github.com/Azure/azure-functions-core-tools#installing)
3. Visual Studio Code on one of the supported platforms. 
4. .NET 6 is the target framework for the steps below. [11](https://dotnet.microsoft.com/pt-br/download/dotnet/6.0)
5. The C# extension for Visual Studio Code.
6. The Azure Functions extension for Visual Studio Code.

### **Create your local project**
In this section, it will be explained how tp use Visual Studio Code to create a local Azure Functions project in C#. 
Choose the Azure icon in the Activity bar, then in the Workspace area, select *Add....*.
Finally, select *Create Function*....

A pop-up message will likely appear prompting you to create a new project, if it does select *Create new project*.

Choose a directory location for your project workspace and choose *Select*.

Provide the following information at the prompts:
1. Select a language: Choose C#.
2. Select a .NET runtime: Choose .NET 6
3. Select a template for your project's first function: Choose HTTP trigger.
4. Provide a function name: Type HttpExample.
5. Provide a namespace: Type My.Function.
6. Authorization level: Choose Anonymous, which enables anyone to call your function endpoint.
10. Select how you would like to open your project: Choose Add to workspace.

Using this information, Visual Studio Code generates an Azure Functions project with an HTTP trigger.

### **Run the function locally**
Visual Studio Code integrates with Azure Functions Core tools to let you run this project on your local development computer before you publish to Azure.

Make sure the terminal is open in Visual Studio Code. You can open the terminal by selecting *Terminal* and then *New Terminal* in the menu bar.

Press F5 to start the function app project in the debugger. Output from Core Tools is displayed in the Terminal panel. Your app starts in the Terminal panel. You can see the URL endpoint of your HTTP-triggered function running locally.

The endpoint of your HTTP-triggered function is displayed in the **Terminal** panel.

With Core Tools running, go to the *Azure: Functions* area. Under *Functions*, expand *Local Project > Functions*. Right-click the HttpExample function and choose *Execute Function Now....*

In Enter request body type the request message body value of *{ "name": "Azure" }*. Press Enter to send this request message to your function. When the function executes locally and returns a response, a notification is raised in Visual Studio Code. Information about the function execution is shown in Terminal panel.

Press *Shift + F5* to stop Core Tools and disconnect the debugger.

After you've verified that the function runs correctly on your local computer, it's time to use Visual Studio Code to publish the project directly to Azure.

### **Sign in to Azure**
Before you can publish your app, you must sign in to Azure. If you're already signed in, go to the next section.

If you aren't already signed in, choose the Azure icon in the Activity bar, then in the Azure: *Functions* area, choose *Sign in to Azure....*

When prompted in the browser, choose your Azure account and sign in using your Azure account credentials.

After you've successfully signed in, you can close the new browser window. The subscriptions that belong to your Azure account are displayed in the Side bar.

### *Create resources in Azure*
In this section, you create the Azure resources you need to deploy your local function app.

Choose the Azure icon in the Activity bar, then in the Resources area select the *Create resource...* button.

Provide the following information at the prompts:

1. Select *Create Function App in Azure...*
2. Enter a globally unique name for the function app: Type a name that is valid in a URL path. The name you type is validated to make sure that it's unique in Azure Functions.
3. Select a runtime stack: Use the same choice you made in the Create your local project section above.
4. Select a location for new resources: For better performance, choose a region near you.
5. Select subscription: Choose the subscription to use. You won't see this if you only have one subscription.

When completed, the following Azure resources are created in your subscription, using names based on your function app name:

1. A [resource group](#resource-group), which is a logical container for related resources.
2. A standard [Azure Storage account](#azure-storage-account), which maintains state and other information about your projects.
3. A [consumption plan](#compare-azure-functions-hosting-options), which defines the underlying host for your serverless function app.
4. A [function app](#function-app), which provides the environment for executing your function code. A function app lets you group functions as a logical unit for easier management, deployment, and sharing of resources within the same hosting plan.
5. An Application Insights instance connected to the function app, which tracks usage of your serverless function.

TBD: approfondire questi elementi

### **Deploy the code**
In the WORKSPACE section of the Azure bar select the *Deploy...* button, and then select *Deploy to Function App...*.

When prompted to Select a resource, choose the function app you created in the previous section.

Confirm that you want to deploy your function by selecting Deploy on the confirmation prompt.

### **Run the function in Azure**
Back in the Resources area in the side bar, expand your subscription, your new function app, and Functions. Right-click the HttpExample function and choose Execute Function Now....

Execute function now in Azure from Visual Studio Code

In Enter request body you see the request message body value of { "name": "Azure" }. Press Enter to send this request message to your function.

When the function executes in Azure and returns a response, a notification is raised in Visual Studio Code.

[12](https://learn.microsoft.com/en-us/training/modules/develop-azure-functions/5-create-function-visual-studio-code)

### **Connect to storage**

Azure Functions lets you connect Azure services and other resources to functions without having to write your own integration code. These bindings, which represent both input and output, are declared within the function definition. Data from bindings is provided to the function as parameters. A trigger is a special type of input binding. Although a function has only one trigger, it can have multiple input and output bindings.

In this section, you learn how to use Visual Studio Code to connect Azure Storage to the function you created in the previous steps. The output binding that you add to this function writes data from the HTTP request to a message in an Azure Queue storage queue.

Most bindings require a stored connection string that Functions uses to access the bound service. To make it easier, you use the storage account that you created with your function app. The connection to this account is already stored in an app setting named *AzureWebJobsStorage*.

**Configure your local environment**
Before you begin, you must meet the following requirements:

1. Install the Azure Storage extension for Visual Studio Code.
2. Install Azure Storage Explorer. Storage Explorer is a tool that you'll use to examine queue messages generated by your output binding. Storage Explorer is supported on macOS, Windows, and Linux-based operating systems.
3. Install .NET Core CLI tools.

We are assuming that you're already signed in to your Azure subscription from Visual Studio Code. 

**Download the function app settings**
In the previous section, you created a function app in Azure along with the required storage account. The connection string for this account is stored securely in the app settings in Azure. In this section, you write messages to a Storage queue in the same account. To connect to your storage account when running the function locally, you must download app settings to the local.settings.json file.

Press F1 to open the command palette, then search for and run the command *Azure Functions: Download Remote Settings....*.

Choose the function app you created in the previous article. Select *Yes to all* to overwrite the existing local settings.


Copy the value *AzureWebJobsStorage*, which is the key for the storage account connection string value. You use this connection to verify that the output binding works as expected.

**Register binding extensions**
Because you're using a Queue storage output binding, you must have the Storage bindings extension installed before you run the project.

Except for HTTP and timer triggers, bindings are implemented as extension packages. Run the following dotnet add package command in the Terminal window to add the Storage extension package to your project.

```
dotnet add package Microsoft.Azure.WebJobs.Extensions.Storage 
```

Now, you can add the storage output binding to your project.

**Add an output binding**
In Functions, each type of binding requires a direction, type, and a unique name to be defined in the function.json file. The way you define these attributes depends on the language of your function app.

In a C# project, the bindings are defined as binding attributes on the function method. Specific definitions depend on whether your app runs in-process (C# class library) or in an isolated worker process.

Open the HttpExample.cs project file and add the following parameter to the Run method definition:

```
[Queue("outqueue"),StorageAccount("AzureWebJobsStorage")] ICollector<string> msg,
```

The msg parameter is an *ICollector<T>* type, representing a collection of messages written to an output binding when the function completes. In this case, the output is a storage queue named outqueue. The StorageAccountAttribute sets the connection string for the storage account. This attribute indicates the setting that contains the storage account connection string and can be applied at the class, method, or parameter level. In this case, you could omit *StorageAccountAttribute* because you're already using the default storage account.

The Run method definition must now look like the following code:

```
[FunctionName("HttpExample")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req, 
    [Queue("outqueue"),StorageAccount("AzureWebJobsStorage")] ICollector<string> msg, 
    ILogger log)
```

**Add code that uses the output binding**
After the binding is defined, you can use the name of the binding to access it as an attribute in the function signature. By using an output binding, you don't have to use the Azure Storage SDK code for authentication, getting a queue reference, or writing data. The Functions runtime and queue output binding do those tasks for you.


Add code that uses the msg output binding object to create a queue message. Add this code before the method returns.

```
if (!string.IsNullOrEmpty(name))
{
    // Add a message to the output collection.
    msg.Add(name);
}
```
At this point, your function must look as follows:

```
[FunctionName("HttpExample")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req, 
    [Queue("outqueue"),StorageAccount("AzureWebJobsStorage")] ICollector<string> msg, 
    ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string name = req.Query["name"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    name = name ?? data?.name;

    if (!string.IsNullOrEmpty(name))
    {
        // Add a message to the output collection.
        msg.Add(name);
    }
    return name != null
        ? (ActionResult)new OkObjectResult($"Hello, {name}")
        : new BadRequestObjectResult("Please pass a name on the query string or in the request body");
}
```
**Connect Storage Explorer to your account*
Run the Azure Storage Explorer tool, select the connect icon on the left, and select Add an account.

In the Connect dialog, choose Add an Azure account, choose your Azure environment, and then select Sign in....

After you successfully sign in to your account, you see all of the Azure subscriptions associated with your account. Choose your subscription and select Open Explorer.

**Examine the output queue**
In Visual Studio Code, press F1 to open the command palette, then search for and run the command *Azure Storage: Open in Storage Explorer* and choose your storage account name. Your storage account opens in the Azure Storage Explorer.

Expand the Queues node, and then select the queue named outqueue.

The queue contains the message that the queue output binding created when you ran the HTTP-triggered function. If you invoked the function with the default name value of Azure, the queue message is Name passed to the function: Azure.

Run the function again, send another request, and you see a new message in the queue.

Now, it's time to republish the updated function app to Azure.

**Redeploy and verify the updated app**
In Visual Studio Code, press F1 to open the command palette. In the command palette, search for and select *Azure Functions: Deploy to function app...*.

Choose the function app that you created in the first section. Because you're redeploying your project to the same app, select Deploy to dismiss the warning about overwriting files.

After the deployment completes, you can again use the *Execute Function Now...* feature to trigger the function in Azure.

Again view the message in the storage queue to verify that the output binding generates a new message in the queue.

[reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-add-output-binding-storage-queue-vs-code?pivots=programming-language-csharp&tabs=in-process)

### Delete a Function

In Azure, resources refer to function apps, functions, storage accounts, and so forth. They're grouped into resource groups, and you can delete everything in a group by deleting the group.

You've created resources to have a function running. You may be billed for these resources, depending on your account status and service pricing. If you don't need the resources anymore, here's how to delete them:

In Visual Studio Code, press F1 to open the command palette. In the command palette, search for and select Azure: Open in portal.

Choose your function app and press Enter. The function app page opens in the Azure portal.

In the Overview tab, select the named link next to Resource group.

Screenshot of select the resource group to delete from the function app page.

On the Resource group page, review the list of included resources, and verify that they're the ones you want to delete.

Select *Delete resource group*, and follow the instructions.

Deletion may take a couple of minutes. When it's done, a notification appears for a few seconds. You can also select the bell icon at the top of the page to view the notification.

## Monitor executions in Azure Functions

Azure Functions offers built-in integration with [Azure Application Insights](#azure-application-insights) to monitor functions executions. This article provides an overview of the monitoring capabilities provided by Azure for monitoring Azure Functions.

Application Insights collects log, performance, and error data. By automatically detecting performance anomalies and featuring powerful analytics tools, you can more easily diagnose issues and better understand how your functions are used. These tools are designed to help you continuously improve performance and usability of your functions. You can even use Application Insights during local function app project development. For more information, see What is Application Insights?.

As Application Insights instrumentation is built into Azure Functions, you need a valid instrumentation key to connect your function app to an Application Insights resource. The instrumentation key is added to your application settings as you create your function app resource in Azure. If your function app doesn't already have this key, you can set it manually.

You can also monitor the function app itself by using [Azure Monitor](#azure-monitor).

## Add on

### Event Hubs and IoT Hub Triggers

Event Hubs and IoT Hub are two different services offered by Azure for handling streaming data. Both services can be used as triggers in Azure Functions.

An Event Hubs trigger allows you to read messages from an Azure Event Hub in real-time. Azure Event Hubs is a highly scalable and highly available event processing service that can ingest millions of events per second. With an Event Hubs trigger, you can process these events as they arrive, allowing you to build real-time data processing applications.

An IoT Hub trigger, on the other hand, allows you to read messages from an Azure IoT Hub. Azure IoT Hub is a fully managed service that enables reliable and secure bi-directional communications between IoT devices and the cloud. With an IoT Hub trigger, you can process messages from IoT devices as they arrive in the cloud, enabling you to build IoT solutions that can react to changes in real-time.

Both triggers can be used in Azure Functions to execute a piece of code in response to incoming messages from Event Hubs or IoT Hub. This code can be written in a variety of languages, including C#, Java, Python, and Node.js, and can be hosted in a serverless environment provided by Azure Functions.

[reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-iot-trigger?tabs=in-process%2Cfunctionsv2%2Cextensionv5&pivots=programming-language-csharp)
[reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs-trigger?tabs=in-process%2Cfunctionsv2%2Cextensionv5&pivots=programming-language-csharp)

### EventProcessorHost

EventProcessorHost is a class in the Azure Event Hubs library that provides a higher-level abstraction for processing events from an Azure Event Hub. It simplifies the process of reading events from a partitioned event stream and provides features such as load balancing, checkpointing, and automatic recovery from failures.

When you use EventProcessorHost, you define an event handler method that will be called for each event that is received from the event hub. The EventProcessorHost will then take care of creating an event processor for each partition of the event stream and distributing the partitions across multiple instances of your application to ensure high availability and scalability.

The EventProcessorHost also includes a checkpointing mechanism that allows you to save the position of the last processed event for each partition. This way, if your application crashes or is restarted, it can resume processing events from where it left off instead of reprocessing events that have already been processed.

Overall, EventProcessorHost provides a simple and reliable way to process events from Azure Event Hubs at scale, without having to manage low-level details such as partitioning, load balancing, and checkpointing.

[reference](#https://learn.microsoft.com/it-it/azure/event-hubs/event-hubs-event-processor-host)

### Resource Group

A resource group is a container that holds related resources for an Azure solution. The resource group can include all the resources for the solution, or only those resources that you want to manage as a group. You decide how you want to allocate resources to resource groups based on what makes the most sense for your organization. Generally, add resources that share the same lifecycle to the same resource group so you can easily deploy, update, and delete them as a group.

The resource group stores metadata about the resources. Therefore, when you specify a location for the resource group, you are specifying where that metadata is stored. For compliance reasons, you may need to ensure that your data is stored in a particular region.

[reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

### Azure Storage Account

An Azure storage account contains all of your Azure Storage data objects, including blobs, file shares, queues, tables, and disks. The storage account provides a unique namespace for your Azure Storage data that's accessible from anywhere in the world over HTTP or HTTPS. Data in your storage account is durable and highly available, secure, and massively scalable.

[reference](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)

### Function App

A function app provides an execution context in Azure in which your functions run. As such, it is the unit of deployment and management for your functions. A function app is composed of one or more individual functions that are managed, deployed, and scaled together. All of the functions in a function app share the same pricing plan, deployment method, and runtime version. Think of a function app as a way to organize and collectively manage your functions.

### Azure Application Insights
Application Insights is an extension of Azure Monitor and provides Application Performance Monitoring (also known as “APM”) features. APM tools are useful to monitor applications from development, through test, and into production in the following ways:

- Proactively understand how an application is performing.
- Reactively review application execution data to determine the cause of an incident.
- In addition to collecting Metrics and application Telemetry data, which describe application activities and health, Application Insights can also be used to collect and store application trace logging data.

The log trace is associated with other telemetry to give a detailed view of the activity. Adding trace logging to existing apps only requires providing a destination for the logs; the logging framework rarely needs to be changed.

Application Insights provides other features including, but not limited to:

1. *Live Metrics* – observe activity from your deployed application in real time with no effect on the host environment
2. *Availability* – also known as “Synthetic Transaction Monitoring”, probe your applications external endpoint(s) to test the overall availability and responsiveness over time
3. *GitHub or Azure DevOps integration* – create GitHub or Azure DevOps work items in context of Application Insights data
Usage – understand which features are popular with users and how users interact and use your application
4. *Smart Detection* – automatic failure and anomaly detection through proactive telemetry analysis

In addition, Application Insights supports Distributed Tracing, also known as “distributed component correlation”. This feature allows searching for and visualizing an end-to-end flow of a given execution or transaction. The ability to trace activity end-to-end is increasingly important for applications that have been built as distributed components or microservices.

The Application Map allows a high level top-down view of the application architecture and at-a-glance visual references to component health and responsiveness.

[reference](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net)

### Azure Monitor

Azure Monitor is a service provided by Microsoft Azure that helps you maximize the performance and availability of your applications and services running on Azure. It provides a comprehensive monitoring solution that can collect data from a variety of sources and provide insights into the health and performance of your applications, infrastructure, and network.

Azure Monitor collects and analyzes telemetry data from different sources such as application logs, metrics, and events from Azure services and virtual machines. It also supports custom data sources through the use of Application Insights, Log Analytics, and other monitoring tools.

Azure Monitor provides a centralized dashboard that allows you to view and analyze the collected data in real-time. You can use it to visualize performance metrics, track application and infrastructure availability, and get alerts when issues are detected.

Some key features of Azure Monitor include:

- Metrics Explorer: Allows you to visualize and analyze metrics collected from Azure services and virtual machines.
- Log Analytics: Provides a powerful query language for searching and analyzing log data from various sources.
- Application Insights: Provides detailed insights into the performance and usage of your web applications.
- Alerts: Allows you to set up alert rules to notify you when specific conditions are met.

Overall, Azure Monitor is a powerful and flexible monitoring solution that provides comprehensive insights into the health and performance of your applications and services running on Azure.

[reference](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)