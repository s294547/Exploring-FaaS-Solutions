# AWS LAMBDAS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [AWS](#aws)
	1. [Overview](#overview)
	2. [Infrastructure](#infrastructure)
		1. [Regions](#regions)
		2. [Availability Zones](#availability-zone)
		3. [Local Zones](#local-zones)
		4. [Wavelength Zones](#wavelength-zones)
	2. [Services](#services)
		1. [Amazon API Gateway](#amazon-api-gateway)
		2. [Amazon S3](#amazon-s3)
		3. [Amazon DynamoDB](#amazon-dynamodb)
		4. [Amazon Kinesis](#amazon-kinesis)
		5. [AWS Identity and Access Management (IAM)](#aws-iam)
		6. [Amazon CloudWatch](#amazon-cloudwatch)
		7. [AWS IoT Core](#aws-iot-core)
3. [AWS Lambda](#aws-lambda)
	1. [Overview](#overview-1)
	2. [Lambda Concepts](#lambda-concepts)
	3. [Lambda Execution Environment](#lambda-execution-environment)
		1. [Lambda Execution Environment Lifecycle](#lambda-execution-enironment-lifecycle)
	4. [Lambda Runtimes](#lambda-runtimes)
		1. [Custom AWS LambdaRuntimes](#custom-aws-lambda-runtimes)
	5. [Lambda Deployment Packages](#lambda-deployment-packages)
		1. [Container Images](#container-images)
		2. [Zip file archives](#zip-file-archives)
	6. [VPC Networking](#vpc-networking)
	7. [Provisioned Concurrency](#provisioned-concurrency)
	8. [Lambda Function Scaling](#lambda-function-scaling)
	9. [Lambda Permissions](#lambda-permissions)
	10. [Invoking Lambda Functions](#invoking-lambda-functions)
		1. [Synchronous Invocation](#synchronous-invocation)
		2. [Asynchronous Invocation](#asynchronous-invocation)
		3. [Lambda event source Mappings](#lambda-event-source-mappings)
	11. [Lambda Function States](#lambda-function-states)
	12. [Lambda Extensions](#lambda-extensions)
	13. [Monitoring Lambda applications](#monitoring-lambda-applications)
4. [Create an AWS Lambda](#create-an-aws-lambda)
	1. [Create an execution role](#create-an-execution-role)
    2. [Create a function](#create-a-function)
5. [AWS Lambda with AWS IoT](#aws-lambda-with-aws-iot)

## Introduction

This file will contain all the retrieved informations about AWS and, in particular, about AWS Lambda Service. 

## AWS

### Overview

AWS provides on-demand delivery of technology services through the Internet with pay-as-you-go pricing. This is known as cloud computing.

The AWS Cloud encompasses a broad set of global cloud-based products that includes compute, storage, databases, analytics, networking, mobile, developer tools, management tools, IoT, security, and enterprise applications: on-demand, available in seconds, with pay-as-you-go pricing. With over 200 fully featured services available from data centers globally, the AWS Cloud has what you need to develop, deploy, and operate your applications, all while lowering costs, becoming more agile, and innovating faster.

For example, with the AWS Cloud, you can spin up a virtual machine, specifying the number of vCPU cores, memory, storage, and other characteristics in seconds, and pay for the infrastructure in per-second increments only while it is running. One benefit of the AWS global infrastructure network is that you can provision resources in the Region or Regions that best serve your specific use case. When you are done with the resources, you can simply delete them. With this built-in flexibility and scalability, you can build an application to serve your first customer, and then scale to serve your next 100 million.

[reference](https://aws.amazon.com/getting-started/cloud-essentials/)

### Infrastructure

With the cloud, you can expand to new geographic regions and deploy globally in minutes. For example, AWS has infrastructure all over the world, so developers can deploy applications in multiple physical locations with just a few clicks. By putting your applications in closer proximity to your end users, you can reduce latency and improve the user experience.
 
AWS is steadily expanding global infrastructure to help our customers achieve lower latency and higher throughput, and to ensure that their data resides only in the AWS Region they specify. As our customers grow their businesses, AWS will continue to provide infrastructure that meets their global requirement.

[reference](https://aws.amazon.com/getting-started/cloud-essentials/)

#### Regions

AWS has the concept of a Region, which is a physical location around the world where we cluster data centers. We call each group of logical data centers an Availability Zone. Each AWS Region consists of a minimum of three, isolated, and physically separate AZs within a geographic area. Unlike other cloud providers, who often define a region as a single data center, the multiple AZ design of every AWS Region offers advantages for customers. Each AZ has independent power, cooling, and physical security and is connected via redundant, ultra-low-latency networks. AWS customers focused on high availability can design their applications to run in multiple AZs to achieve even greater fault-tolerance. AWS infrastructure Regions meet the highest levels of security, compliance, and data protection.

AWS provides a more extensive global footprint than any other cloud provider, and to support its global footprint and ensure customers are served across the world, AWS opens new Regions rapidly. AWS maintains multiple geographic Regions, including Regions in North America, South America, Europe, China, Asia Pacific, South Africa, and the Middle East.

#### Availability Zones

An Availability Zone (AZ) is one or more discrete data centers with redundant power, networking, and connectivity in an AWS Region. AZs give customers the ability to operate production applications and databases that are more highly available, fault tolerant, and scalable than would be possible from a single data center. All AZs in an AWS Region are interconnected with high-bandwidth, low-latency networking, over fully redundant, dedicated metro fiber providing high-throughput, low-latency networking between AZs. All traffic between AZs is encrypted. The network performance is sufficient to accomplish synchronous replication between AZs. AZs make partitioning applications for high availability easy. If an application is partitioned across AZs, companies are better isolated and protected from issues such as power outages, lightning strikes, tornadoes, earthquakes, and more. AZs are physically separated by a meaningful distance, many kilometers, from any other AZ, although all are within 100 km (60 miles) of each other.

#### Local Zones

AWS Local Zones place compute, storage, database, and other select AWS services closer to end-users. With AWS Local Zones, you can easily run highly-demanding applications that require single-digit millisecond latencies to your end-users such as media & entertainment content creation, real-time gaming, reservoir simulations, electronic design automation, and machine learning.

Each AWS Local Zone location is an extension of an AWS Region where you can run your latency sensitive applications using AWS services such as Amazon Elastic Compute Cloud, Amazon Virtual Private Cloud, Amazon Elastic Block Store, Amazon File Storage, and Amazon Elastic Load Balancing in geographic proximity to end-users. AWS Local Zones provide a high-bandwidth, secure connection between local workloads and those running in the AWS Region, allowing you to seamlessly connect to the full range of in-region services through the same APIs and tool sets.

#### Wavelength Zones

AWS Wavelength enables developers to build applications that deliver single-digit millisecond latencies to mobile devices and end-users. AWS developers can deploy their applications to Wavelength Zones, AWS infrastructure deployments that embed AWS compute and storage services within the telecommunications providers’ datacenters at the edge of the 5G networks, and seamlessly access the breadth of AWS services in the region. This enables developers to deliver applications that require single-digit millisecond latencies such as game and live video streaming, machine learning inference at the edge, and augmented and virtual reality (AR/VR). AWS Wavelength brings AWS services to the edge of the 5G network, minimizing the latency to connect to an application from a mobile device. Application traffic can reach application servers running in Wavelength Zones without leaving the mobile provider’s network. This reduces the extra network hops to the Internet that can result in latencies of more than 100 milliseconds, preventing customers from taking full advantage of the bandwidth and latency advancements of 5G.

[reference](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/?p=ngi&loc=2&refid=cb95ae0c-bf32-4903-b47a-afbe43299b20)

### Services

#### Amazon API Gateway
Amazon API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. APIs act as the "front door" for applications to access data, business logic, or functionality from your backend services. Using API Gateway, you can create RESTful APIs and WebSocket APIs that enable real-time two-way communication applications. API Gateway supports containerized and serverless workloads, as well as web applications.

API Gateway handles all the tasks involved in accepting and processing up to hundreds of thousands of concurrent API calls, including traffic management, CORS support, authorization and access control, throttling, monitoring, and API version management. API Gateway has no minimum fees or startup costs. You pay for the API calls you receive and the amount of data transferred out and, with the API Gateway tiered pricing model, you can reduce your cost as your API usage scales.

[reference](#https://aws.amazon.com/api-gateway/)

#### Amazon S3
Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. Customers of all sizes and industries can use Amazon S3 to store and protect any amount of data for a range of use cases, such as data lakes, websites, mobile applications, backup and restore, archive, enterprise applications, IoT devices, and big data analytics. Amazon S3 provides management features so that you can optimize, organize, and configure access to your data to meet your specific business, organizational, and compliance requirements.

##### Buckets
A bucket is a container for objects stored in Amazon S3. When you create a bucket, you enter a bucket name and choose the AWS Region where the bucket will reside.

Buckets also:

- Organize the Amazon S3 namespace at the highest level.
- Identify the account responsible for storage and data transfer charges.
- Provide access control options, such as bucket policies, access control lists (ACLs), and S3 Access Points, that you can use to manage access to your Amazon S3 resources.
- Serve as the unit of aggregation for usage reporting.

##### Objects
Objects are the fundamental entities stored in Amazon S3. Objects consist of object data and metadata. The metadata is a set of name-value pairs that describe the object. These pairs include some default metadata, such as the date last modified, and standard HTTP metadata, such as Content-Type. You can also specify custom metadata at the time that the object is stored.

An object is uniquely identified within:
- a bucket by a key (name)  
- a version ID (if S3 Versioning is enabled on the bucket).

[reference](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)

#### Amazon DynamoDB
Amazon DynamoDB is a NoSQL database that supports key-value and document data models. Developers can use DynamoDB to build modern, serverless applications that can start small and scale globally to support petabytes of data and tens of millions of read and write requests per second. DynamoDB is designed to run high-performance, internet-scale applications that would overburden traditional relational databases.

Main features:
- it supports tables of virtually any size with horizontal scaling
	1. DynamoDB supports both key-value and document data models. This enables DynamoDB to have a flexible schema.
	2. DynamoDB Accelerator (DAX) is an in-memory cache that delivers fast read performance for your tables at scale by enabling you to use a fully managed in-memory cache.
	3. DynamoDB global tables replicate your data automatically across your choice of AWS Regions and automatically scale capacity to accommodate your workloads
- serverless! 
	1. DynamoDB provides capacity modes for each table: on-demand and provisioned. For workloads that are less predictable, on-demand capacity mode takes care of managing capacity for you, and you pay only for what you consume.
	2. For tables using on-demand capacity mode, DynamoDB instantly accommodates your workloads as they ramp up or down to any previously reached traffic level.
	3. For tables using provisioned capacity, DynamoDB delivers automatic scaling of throughput and storage based on your previously set capacity by monitoring the performance usage of your application.
- enterprise ready
	1. DynamoDB provides native, server-side support for transactions.
	2. DynamoDB encrypts all customer data at rest by default.
	3. PITR provides continuous backups of your DynamoDB table data, and you can restore that table to any point in time up to the second during the preceding 35 days.
	4. DynamoDB on-demand backup capability creates full backups of your tables for long-term retention, and archiving for regulatory compliance needs. Backup and restore actions run with no impact on table performance or availability.

[reference](https://aws.amazon.com/dynamodb/features/)

#### Amazon Kinesis
Amazon Kinesis makes it easy to collect, process, and analyze real-time, streaming data so you can get timely insights and react quickly to new information. Amazon Kinesis offers key capabilities to cost-effectively process streaming data at any scale, along with the flexibility to choose the tools that best suit the requirements of your application. With Amazon Kinesis, you can ingest real-time data such as video, audio, application logs, website clickstreams, and IoT telemetry data for machine learning, analytics, and other applications. Amazon Kinesis enables you to process and analyze data as it arrives and respond instantly instead of having to wait until all your data is collected before the processing can begin.

Amazon Kinesis capabilities:
1. *Amazon Kinesis Video Streams*: it makes it easy to securely stream video from connected devices to AWS for analytics, machine learning (ML), and other processing.
2. *Amazon Kinesis Data Streams*: it is a scalable and durable real-time data streaming service that can continuously capture gigabytes of data per second from hundreds of thousands of sources. 
3. *Amazon Kinesis Data Firehose*: it is the easiest way to capture, transform, and load data streams into AWS data stores for near real-time analytics with existing business intelligence tools.
4. *Amazon Kinesis Data Analytics*: it is the easiest way to process data streams in real time with SQL or Apache Flink without having to learn new programming languages or processing frameworks.

[reference](https://aws.amazon.com/kinesis/)

#### AWS IAM
With AWS Identity and Access Management (IAM), you can specify who or what can access services and resources in AWS, centrally manage fine-grained permissions, and analyze access to refine permissions across AWS.

[reference](https://aws.amazon.com/iam/)

#### Amazon Virtual Private Cloud
Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

##### IP Addressing
IP addresses enable resources in your VPC to communicate with each other and with resources over the internet. Amazon VPC supports both the IPv4 and IPv6 addressing protocols. In a VPC, you can create IPv4-only, dual-stack, and IPv6-only subnets and launch Amazon EC2 instances in these subnets. Amazon also gives you multiple options to assign public IP addresses to your instances. You can use the Amazon provided public IPv4 addresses, Elastic IPv4 addresses, or an IP address from the Amazon provided IPv6 CIDRs. Apart from this, you have the option to bring your own IPv4 or IPv6 addresses within the Amazon VPC that can be assigned to these instances.  

[reference](https://aws.amazon.com/vpc/features/?nc1=h_ls)

#### Amazon CloudWatch

Amazon CloudWatch is a monitoring and management service that provides data and actionable insights for AWS, hybrid, and on-premises applications and infrastructure resources. You can collect and access all your performance and operational data in the form of logs and metrics from a single platform rather than monitoring them in silos (server, network, or database). CloudWatch enables you to monitor your complete stack (applications, infrastructure, network, and services) and use alarms, logs, and events data to take automated actions and reduce mean time to resolution (MTTR). This frees up important resources and allows you to focus on building applications and business value.

[reference](https://aws.amazon.com/cloudwatch/features/)

#### AWS IoT Core

AWS IoT Core lets you connect billions of IoT devices and route trillions of messages to AWS services without managing infrastructure.

This is the service that the devices directly connect to, for transmitting data. It allows for several communication protocols like MQTT, HTTPS, MQTT over WebSocket, and even LoRaWAN. And the communication is secured with end-to-end encryption and also authentication. Once the data is received by the IoT Core, you can define rules to transfer it forward to other services (like lambda), or take some action based on that data.

[iot-core](./iot-core.png)
[reference](https://aws.amazon.com/iot-core/?nc=sn&loc=2&dn=3)

## AWS Lambda

### Overview

AWS Lambda is a serverless compute service that runs your code in response to events and automatically manages the underlying compute resources for you. These events may include changes in state or an update, such as a user placing an item in a shopping cart on an ecommerce website. You can use AWS Lambda to extend other AWS services with custom logic, or create your own backend services that operate at AWS scale, performance, and security. AWS Lambda automatically runs code in response to multiple events, such as HTTP requests via [Amazon API Gateway](#amazon-api-gateway), modifications to objects in [Amazon Simple Storage Service](#amazon-s3) buckets, table updates in [Amazon DynamoDB](#amazon-dynamodb), and [Amazon Kinesis](#amazon-kinesis) stream.

Lambda runs your code on high availability compute infrastructure and performs all the administration of your compute resources. This includes server and operating system maintenance, capacity provisioning and automatic scaling, code and security patch deployment, and code monitoring and logging. All you need to do is supply the code.

It is easy to get started with AWS Lambda:
1. First, you create your function by uploading your code (or building it right in the Lambda console) and choosing the memory, timeout period, and [AWS Identity and Access Management (IAM)](#aws-iam) role.
2. Then, you specify the AWS resource to trigger the function, which can be a particular Amazon S3 bucket, Amazon DynamoDB table, or  Amazon Kinesis stream. When the resource changes, Lambda will run your function, launching and managing the compute resources as needed to keep up with incoming requests

**Bring your own code**
With AWS Lambda, there are no new languages, tools, or frameworks to learn. You can use any third- party library, even native ones. You can also package any code (frameworks, SDKs, libraries, and more) as a Lambda Layer, and manage and share them easily across multiple functions. Lambda natively supports Java, Go, PowerShell, Node.js, C#, Python, and Ruby code, and provides a Runtime API allowing you to use any additional programming languages to author your functions.

**Completely automated administration**
AWS Lambda manages all the infrastructure to run your code on highly available, fault tolerant infrastructure, freeing you to focus on building differentiated backend services. With Lambda, you never have to update the underlying operating system (OS) when a patch is released, or worry about resizing or adding new servers as your usage grows. AWS Lambda seamlessly deploys your code, handles all the administration, maintenance, and security patches, and provides built-in logging and monitoring through [Amazon CloudWatch](#amazon-cloudwatch).

**Built-in fault tolerance**
AWS Lambda maintains compute capacity across multiple [Availability Zones (AZs)](#availability-zones) in each AWS Region to help protect your code against individual machine or data center facility failures. Both AWS Lambda and the functions running on the service deliver predictable and reliable operational performance. AWS Lambda is designed to provide high availability for both the service itself and the functions it operates. There are no maintenance windows or scheduled downtimes.

**Package and deploy functions as container images**
AWS Lambda supports function packaging and deployment as container images, making it easy for customers to build Lambda-based applications using familiar container image tooling, workflows, and dependencies. Customers also benefit from Lambda’s operational simplicity, automatic scaling with sub-second startup times, high availability, pay-for-use billing model, and native integrations with over 200 AWS services and software-as-a service (SaaS) applications. Enterprise customers can use a consistent set of tools with both their Lambda and containerized applications, simplifying central governance requirements such as security scanning and image signing.

**Automatic scaling**
AWS Lambda invokes your code only when needed, and automatically scales to support the rate of incoming requests without any manual configuration. There is no limit to the number of requests your code can handle. AWS Lambda typically starts running your code within milliseconds of an event. Since Lambda scales automatically, the performance remains consistently high as the event frequency increases. Since your code is stateless, Lambda can start as many instances as needed without lengthy deployment and configuration delays.

**Orchestrate multiple functions**
Build AWS Step Functions workflows to coordinate multiple AWS Lambda functions for complex or long-running tasks. Step Functions lets you define workflows that trigger a collection of Lambda functions using sequential, parallel, branching, and error-handling steps. With Step Functions and Lambda, you can build stateful, long-running processes for applications and backends.

**Integrated security model**
AWS Lambda's built-in software development kit (SDK) integrates with AWS Identity and Access Management (IAM) to ensure secure code access to other AWS services. AWS Lambda runs your code within an [Amazon Virtual Private Cloud (VPC)](#amazon-virtual-private-cloud) by default. Optionally, you can configure AWS Lambda resource access behind your own VPC in order to leverage custom security groups and network access control lists. This provides secure Lambda function access to your resources within a VPC. 

**Trust and integrity controls**
Code Signing for AWS Lambda allows you to verify that only unaltered code published by approved developers is deployed in your Lambda functions. You simply create digitally signed code artifacts and configure your Lambda functions to verify the signatures at deployment. This increases the speed and agility of your application development, even within large teams, while enforcing high security standards.
Only pay for what you use
With AWS Lambda, you pay for execution duration rather than server unit. When using Lambda functions, you only pay for requests served and the compute time required to run your code. Billing is metered in increments of one millisecond, enabling easy and cost-effective automatic scaling from a few requests per day to thousands per second. With Provisioned Concurrency, you pay for the amount of concurrency you configure and the duration that you configure it. When Provisioned Concurrency is enabled and your function is executed, you also pay for requests and execution duration. To learn more about pricing, please visit AWS Lambda Pricing.

**Flexible resource model**
Choose the amount of memory you want to allocate to your functions, and AWS Lambda allocates proportional CPU power, network bandwidth, and disk input/output (I/O).

**Integrate Lambda with your favorite operational tools**
AWS Lambda extensions enable easy integration with your favorite monitoring, observability, security, and governance tools. Lambda invokes your function in an execution environment, which provides a secure and isolated runtime where your function code is executed. Lambda extensions run within Lambda’s execution environment, alongside your function code. Lambda extensions can use the AWS Lambda Telemetry API to capture fine grained diagnostic information, such as logs, metrics, and traces, directly from Lambda, and send them to a destination of your choice. You can also use extensions to integrate your preferred security agents with Lambda, all with no operational overhead and minimal impact to your function performance.

[reference](https://aws.amazon.com/lambda/features/?pg=ln&sec=hs)

### Lambda Concepts

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/gettingstarted-concepts.md)

#### Function
A function is a resource that you can invoke to run your code in Lambda. A function has code to process the events that you pass into the function or that other AWS services send to the function.

#### Trigger
A trigger is a resource or configuration that invokes a Lambda function (see [Invoking Lambda Functions](#invoking-lambda-functions)). Triggers include AWS services that you can configure to invoke a function and event source mappings. An event source mapping is a resource in Lambda that reads items from a stream or queue and invokes a function.

#### Event
An event is a JSON-formatted document that contains data for a Lambda function to process. The runtime converts the event to an object and passes it to your function code. When you invoke a function, you determine the structure and contents of the event.

#### Execution Environment
An [execution environment](#lambda-execution-environment) provides a secure and isolated runtime environment for your Lambda function. An execution environment manages the processes and resources that are required to run the function. The execution environment provides lifecycle support for the function and for any extensions associated with your function.

#### Instruction set architecture
The instruction set architecture determines the type of computer processor that Lambda uses to run the function. Lambda provides a choice of instruction set architectures:
- arm64 – 64-bit ARM architecture, for the AWS Graviton2 processor.
- x86_64 – 64-bit x86 architecture, for x86-based processors

#### Deployment package
You deploy your Lambda function code using a [deployment package](#lambda-deployment-packages). Lambda supports two types of deployment packages:
- A .zip file archive that contains your function code and its dependencies. Lambda provides the operating system and runtime for your function.
- A container image that is compatible with the Open Container Initiative (OCI) specification. You add your function code and dependencies to the image. You must also include the operating system and a Lambda runtime.

#### Runtime
The [runtime](#lambda-runtimes) provides a language-specific environment that runs in an execution environment. The runtime relays invocation events, context information, and responses between Lambda and the function. You can use runtimes that Lambda provides, or build your own. If you package your code as a .zip file archive, you must configure your function to use a runtime that matches your programming language. For a container image, you include the runtime when you build the image.

#### Layer
A Lambda layer is a .zip file archive that can contain additional code or other content. A layer can contain libraries, a custom runtime, data, or configuration files.

Layers provide a convenient way to package libraries and other dependencies that you can use with your Lambda functions. Using layers reduces the size of uploaded deployment archives and makes it faster to deploy your code. Layers also promote code sharing and separation of responsibilities so that you can iterate faster on writing business logic.

You can include up to five layers per function. Layers count towards the standard Lambda deployment size quotas. When you include a layer in a function, the contents are extracted to the /opt directory in the execution environment.

By default, the layers that you create are private to your AWS account. You can choose to share a layer with other accounts or to make the layer public. If your functions consume a layer that a different account published, your functions can continue to use the layer version after it has been deleted, or after your permission to access the layer is revoked. However, you cannot create a new function or update functions using a deleted layer version.

Functions deployed as a container image do not use layers. Instead, you package your preferred runtime, libraries, and other dependencies into the container image when you build the image.

#### Extension
[Lambda extensions](#lambda-extensions) enable you to augment your functions. For example, you can use extensions to integrate your functions with your preferred monitoring, observability, security, and governance tools. You can choose from a broad set of tools that AWS Lambda Partners provides, or you can create your own Lambda extensions.

An internal extension runs in the runtime process and shares the same lifecycle as the runtime. An external extension runs as a separate process in the execution environment. The external extension is initialized before the function is invoked, runs in parallel with the function's runtime, and continues to run after the function invocation is complete.

#### Concurrency
[Concurrency](#lambda-function-scaling) is the number of requests that your function is serving at any given time. When your function is invoked, Lambda provisions an instance of it to process the event. When the function code finishes running, it can handle another request. If the function is invoked again while a request is still being processed, another instance is provisioned, increasing the function's concurrency.

Concurrency is subject to quotas at the AWS Region level. You can configure individual functions to limit their concurrency, or to enable them to reach a specific level of concurrency. 

#### Qualifier
When you invoke or view a function, you can include a qualifier to specify a version or alias. A version is an immutable snapshot of a function's code and configuration that has a numerical qualifier. For example, my-function:1. An alias is a pointer to a version that you can update to map to a different version, or split traffic between two versions. For example, my-function:BLUE. You can use versions and aliases together to provide a stable interface for clients to invoke your function.

#### Destination
A destination is an AWS resource where Lambda can send events from an asynchronous invocation. You can configure a destination for events that fail processing. Some services also support a destination for events that are successfully processed.

[destinations](./destinations.png)


### Lambda Execution Environment

Lambda invokes your function in an execution environment, which provides a secure and isolated runtime environment. The execution environment manages the resources required to run your function. The execution environment also provides lifecycle support for the function's runtime and any external extensions associated with your function.

The function's runtime communicates with Lambda using the Runtime API. Extensions communicate with Lambda using the Extensions API. Extensions can also receive log messages and other telemetry from the function by using the Telemetry API.

[Lambda Execution Environment](./lambda-execution-environment.png)

When you create your Lambda function, you specify configuration information, such as the amount of memory available and the maximum execution time allowed for your function. Lambda uses this information to set up the execution environment.

The function's runtime and each external extension are processes that run within the execution environment. Permissions, resources, credentials, and environment variables are shared between the function and the extensions.

#### Lambda execution environment lifecycle

The lifecycle of the execution environment includes the following phases:

1. *Init*: In this phase, Lambda creates or unfreezes an execution environment with the configured resources, downloads the code for the function and all layers, initializes any extensions, initializes the runtime, and then runs the function’s initialization code (the code outside the main handler). The *Init* phase happens either during the first invocation, or in advance of function invocations if you have enabled provisioned concurrency.
The *Init* phase is split into three sub-phases: *Extension init*, *Runtime init*, and *Function init*. These sub-phases ensure that all extensions and the runtime complete their setup tasks before the function code runs.
2. *Invoke*: In this phase, Lambda invokes the function handler. After the function runs to completion, Lambda prepares to handle another function invocation.
3. *Shutdown*: This phase is triggered if the Lambda function does not receive any invocations for a period of time. In the *Shutdown* phase, Lambda shuts down the runtime, alerts the extensions to let them stop cleanly, and then removes the environment. Lambda sends a *Shutdown* event to each extension, which tells the extension that the environment is about to be shut down.

[Lambda Execution Environment Lifecycle](./lambda-execution-lifecycle.png)

Each phase starts with an event that Lambda sends to the runtime and to all registered extensions. The runtime and each extension indicate completion by sending a Next API request. Lambda freezes the execution environment when the runtime and each extension have completed and there are no pending events.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-runtime-environment.md)

### Lambda Runtimes

Lambda supports multiple languages through the use of runtimes. For a function defined as a container image, you choose a runtime and the Linux distribution when you create the container image. To change the runtime, you create a new container image.

When you use a .zip file archive for the deployment package, you choose a runtime when you create the function. To change the runtime, you can update your function's configuration. The runtime is paired with one of the Amazon Linux distributions. The underlying execution environment provides additional libraries and environment variables that you can access from your function code.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-runtimes.md)

#### Custom AWS Lambda runtimes
You can implement an AWS Lambda runtime in any programming language. A runtime is a program that runs a Lambda function's handler method when the function is invoked. You can include a runtime in your function's deployment package in the form of an executable file named bootstrap.

A runtime is responsible for running the function's setup code, reading the handler name from an environment variable, and reading invocation events from the Lambda runtime API. The runtime passes the event data to the function handler, and posts the response from the handler back to Lambda.

Your custom runtime runs in the standard Lambda execution environment. It can be a shell script, a script in a language that's included in Amazon Linux, or a binary executable file that's compiled in Amazon Linux.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/runtimes-custom.md)

### Lambda Deployment Packages 

Your AWS Lambda function's code consists of scripts or compiled programs and their dependencies. You use a deployment package to deploy your function code to Lambda. Lambda supports two types of deployment packages: container images and .zip file archives.

#### Container Images
A container image includes the base operating system, the runtime, Lambda extensions, your application code and its dependencies. 

Lambda provides a set of open-source base images that you can use to build your container image. You upload your container images to Amazon Elastic Container Registry (Amazon ECR), a managed AWS container image registry service. To deploy the image to your function, you specify the Amazon ECR image URL using the Lambda console, the Lambda API, command line tools, or the AWS SDKs.

For more information about Lambda container images, see [Creating Lambda container images](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/images-create.md).

#### .zip file archives
A .zip file archive includes your application code and its dependencies. When you author functions using the Lambda console or a toolkit, Lambda automatically creates a .zip file archive of your code.

When you create functions with the Lambda API, command line tools, or the AWS SDKs, you must create a deployment package. You also must create a deployment package if your function uses a compiled language, or to add dependencies to your function. To deploy your function's code, you upload the deployment package from Amazon Simple Storage Service (Amazon S3) or your local machine.

You can upload a .zip file as your deployment package using the Lambda console, AWS Command Line Interface (AWS CLI), or to an Amazon Simple Storage Service (Amazon S3) bucket.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/gettingstarted-package.md)

### VPC Networking

Amazon Virtual Private Cloud (Amazon VPC) is a virtual network in the AWS cloud, dedicated to your AWS account. You can use Amazon VPC to create a private network for resources such as databases, cache instances, or internal services. 

A Lambda function always runs inside a VPC owned by the Lambda service. Lambda applies network access and security rules to this VPC and Lambda maintains and monitors the VPC automatically. If your Lambda function needs to access the resources in your account VPC, configure the function to access the VPC.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/foundation-networking.md)

### Provisioned Concurrency

There are two types of concurrency controls available:

- *Reserved concurrency* – Reserved concurrency guarantees the maximum number of concurrent instances for the function. When a function has reserved concurrency, no other function can use that concurrency. There is no charge for configuring reserved concurrency for a function.
- *Provisioned concurrency* – Provisioned concurrency initializes a requested number of execution environments so that they are prepared to respond immediately to your function's invocations. Note that configuring provisioned concurrency incurs charges to your AWS account.

When Lambda allocates an instance of your function, the runtime loads your function's code and runs initialization code that you define outside of the handler. If your code and dependencies are large, or you create SDK clients during initialization, this process can take some time. When your function has not been used for some time, needs to scale up, or when you update a function, Lambda creates new execution environments. This causes the portion of requests that are served by new instances to have higher latency than the rest, otherwise known as a cold start.

By allocating provisioned concurrency before an increase in invocations, you can ensure that all requests are served by initialized instances with low latency. Lambda functions configured with provisioned concurrency run with consistent start-up latency, making them ideal for building interactive mobile or web backends, latency sensitive microservices, and synchronously invoked APIs.

Lambda also integrates with Application Auto Scaling, allowing you to manage provisioned concurrency on a schedule or based on utilization.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/provisioned-concurrency.md)


### Lambda Function Scaling
The first time you invoke your function, AWS Lambda creates an instance of the function and runs its handler method to process the event. When the function returns a response, it stays active and waits to process additional events. If you invoke the function again while the first event is being processed, Lambda initializes another instance, and the function processes the two events concurrently. As more events come in, Lambda routes them to available instances and creates new instances as needed. When the number of requests decreases, Lambda stops unused instances to free up scaling capacity for other functions.

The default regional concurrency quota starts at 1,000 instances. 

Your functions' concurrency is the number of instances that serve requests at a given time. For an initial burst of traffic, your functions' cumulative concurrency in a Region can reach an initial level of between 500 and 3000, which varies per Region. Note that the burst concurrency quota is not per-function; it applies to all your functions in the Region.

After the initial burst, your functions' concurrency can scale by an additional 500 instances each minute. This continues until there are enough instances to serve all requests, or until a concurrency limit is reached. When requests come in faster than your function can scale, or when your function is at maximum concurrency, additional requests fail with a throttling error (429 status code).

The following example shows a function processing a spike in traffic. As invocations increase exponentially, the function scales up. It initializes a new instance for any request that can't be routed to an available instance. When the burst concurrency limit is reached, the function starts to scale linearly. If this isn't enough concurrency to serve all requests, additional requests are throttled and should be retried.

[Function Scaling With Concurrency Limit](./scaling-concurrency-limit.png)

- Orange lines: function instances
- Grey lines: Open Requests

The function continues to scale until the account's concurrency limit for the function's Region is reached. The function catches up to demand, requests subside, and unused instances of the function are stopped after being idle for some time. Unused instances are frozen while they're waiting for requests and don't incur any charges.

When your function scales up, the first request served by each instance is impacted by the time it takes to load and initialize your code. If your initialization code takes a long time, the impact on average and percentile latency can be significant. To enable your function to scale without fluctuations in latency, use provisioned concurrency. The following example shows a function with provisioned concurrency processing a spike in traffic.

[Function Scaling with Provisioned Concurrency](./scaling-provisioned-concurrency.png)

Legend

- Orange: Function instances
- Grey: Open requests
- Diagonal lines: Provisioned concurrency
- Vertical lines: Standard concurrency

When you configure a number for provisioned concurrency, Lambda initializes that number of execution environments. Your function is ready to serve a burst of incoming requests with very low latency. Note that configuring provisioned concurrency incurs charges to your AWS account.

When all provisioned concurrency is in use, the function scales up normally to handle any additional requests.

Application Auto Scaling takes this a step further by providing autoscaling for provisioned concurrency. With Application Auto Scaling, you can create a target tracking scaling policy that adjusts provisioned concurrency levels automatically, based on the utilization metric that Lambda emits. Use the Application Auto Scaling API to register an alias as a scalable target and create a scaling policy.

In the following example, a function scales between a minimum and maximum amount of provisioned concurrency based on utilization. When the number of open requests increases, Application Auto Scaling increases provisioned concurrency in large steps until it reaches the configured maximum. The function continues to scale on standard concurrency until utilization starts to drop. When utilization is consistently low, Application Auto Scaling decreases provisioned concurrency in smaller periodic steps.

[Autoscaling with Provisioned Concurrency](./autoscaling-provisioned.png)

**Legend**
- Orange: Function instances
- Grey: Open requests
- Diagonal lines: Provisioned concurrency
- Vertical lines: Standard concurrency

When you invoke your function asynchronously, by using an event source mapping or another AWS service, scaling behavior varies. For example, event source mappings that read from a stream are limited by the number of shards in the stream. Scaling capacity that is unused by an event source is available for use by other clients and event sources. 

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/invocation-scaling.md)

### Lambda Permissions

You can use AWS Identity and Access Management (IAM) to manage access to the Lambda API and resources such as functions and layers. For users and applications in your account that use Lambda, you can create IAM policies that apply to IAM users, groups, or roles.

Every Lambda function has an IAM role called an execution role. In this role, you can attach a policy that defines the permissions that your function needs to access other AWS services and resources. At a minimum, your function needs access to Amazon CloudWatch Logs for log streaming. If your function calls other service APIs with the AWS SDK, you must include the necessary permissions in the execution role's policy. Lambda also uses the execution role to get permission to read from event sources when you use an event source mapping to invoke your function.

To give other accounts and AWS services permission to use your Lambda resources, use a resource-based policy. Lambda resources include functions, versions, aliases, and layer versions. When a user tries to access a Lambda resource, Lambda considers both the user's identity-based policies and the resource's resource-based policy. When an AWS service such as Amazon Simple Storage Service (Amazon S3) calls your Lambda function, Lambda considers only the resource-based policy.

To manage permissions for users and applications in your account, we recommend using an AWS managed policy. You can use these managed policies as-is, or as a starting point for writing your own more restrictive policies. Policies can restrict user permissions by the resource that an action affects, and by additional optional conditions.

If your Lambda functions contain calls to other AWS resources, you might also want to restrict which functions can access those resources. To do this, include the lambda:SourceFunctionArn condition key in a resource-based policy for the target resource. 

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-permissions.md)

### Invoking Lambda Functions

#### Synchronous Invocation
When you invoke a function synchronously, Lambda runs the function and waits for a response. When the function completes, Lambda returns the response from the function's code with additional data, such as the version of the function that was invoked.

[synchronous-invocation](./synchronous-invocation.png)

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/invocation-sync.md)

#### Asynchronous Invocation
Several AWS services, such as Amazon Simple Storage Service (Amazon S3) and Amazon Simple Notification Service (Amazon SNS), invoke functions asynchronously to process events. When you invoke a function asynchronously, you don't wait for a response from the function code. You hand off the event to Lambda and Lambda handles the rest. You can configure how Lambda handles errors, and can send invocation records to a downstream resource to chain together components of your application.

For asynchronous invocation, Lambda places the event in a queue and returns a success response without additional information. A separate process reads events from the queue and sends them to your function

[asynch-invocation](./asynch-invocation.png)

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/invocation-async.md)

#### Lambda event source mappings
An event source mapping is a Lambda resource that reads from an event source and invokes a Lambda function. You can use event source mappings to process items from a stream or queue in services that don't invoke Lambda functions directly. Lambda provides event source mappings for the following services.

Services that Lambda reads events from:
- Amazon DynamoDB
- Amazon Kinesis
- Amazon MQ
- Amazon Managed Streaming for,Apache Kafka (Amazon MSK)
- Self-managed Apache Kafka
- Amazon Simple Queue Service (Amazon SQS)
An event source mapping uses permissions in the function's execution role to read and manage items in the event source. Permissions, event structure, settings, and polling behavior vary by event source. 

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/invocation-eventsourcemapping.md)

### Lambda Function States

Lambda includes a state field in the function configuration for all functions to indicate when your function is ready to invoke. State provides information about the current status of the function, including whether you can successfully invoke the function. Function states do not change the behavior of function invocations or how your function runs the code. Function states include:

1. *Pending* – After Lambda creates the function, it sets the state to pending. While in pending state, Lambda attempts to create or configure resources for the function, such as VPC or EFS resources. Lambda does not invoke a function during pending state. Any invocations or other API actions that operate on the function will fail.
2. *Active* – Your function transitions to active state after Lambda completes resource configuration and provisioning. Functions can only be successfully invoked while active.
3. *Failed* – Indicates that resource configuration or provisioning encountered an error.
4. *Inactive* – A function becomes inactive when it has been idle long enough for Lambda to reclaim the external resources that were configured for it. When you try to invoke a function that is inactive, the invocation fails and Lambda sets the function to pending state until the function resources are recreated. If Lambda fails to recreate the resources, the function is set to the inactive state.

### Lambda Extensions

You can use Lambda extensions to augment your Lambda functions. For example, use Lambda extensions to integrate functions with your preferred monitoring, observability, security, and governance tools. You can choose from a broad set of tools that AWS Lambda Partners provides, or you can create your own Lambda extensions.

Lambda supports external and internal extensions. An external extension runs as an independent process in the execution environment and continues to run after the function invocation is fully processed. Because extensions run as separate processes, you can write them in a different language than the function.

An internal extension runs as part of the runtime process.

You can add extensions to a function using the Lambda console, the AWS Command Line Interface (AWS CLI), or infrastructure as code (IaC) services and tools such as AWS CloudFormation, AWS Serverless Application Model (AWS SAM), and Terraform.

You are charged for the execution time that the extension consumes (in 1 ms increments).

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-extensions.md)

### Monitoring Lambda Applications

AWS Lambda integrates with other AWS services to help you monitor and troubleshoot your Lambda functions. Lambda automatically monitors Lambda functions on your behalf and reports metrics through Amazon CloudWatch. To help you monitor your code when it runs, Lambda automatically tracks the number of requests, the invocation duration per request, and the number of requests that result in an error.

You can use other AWS services to troubleshoot your Lambda functions. 

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-monitoring.md)

### Create an AWS Lambda

You can run JavaScript code with Node.js in AWS Lambda. Lambda provides runtimes for Node.js that run your code to process events. Your code runs in an environment that includes the AWS SDK for JavaScript, with credentials from an AWS Identity and Access Management (IAM) role that you manage.

#### Create an execution role
Lambda functions use an execution role to get permission to write logs to Amazon CloudWatch Logs, and to access other services and resources. If you don't already have an execution role for function development, create one.

1. Open the roles page in the IAM console.
2. Choose Create role.
3. Create a role with the following properties.
    - Trusted entity – Lambda.
    - Permissions – AWSLambdaBasicExecutionRole.
    - Role name – lambda-role.
The AWSLambdaBasicExecutionRole policy has the permissions that the function needs to write logs to CloudWatch Logs.

You can add permissions to the role later, or swap it out for a different role that's specific to a single function.

### Create a function

1. Open the Lambda console.
2. Choose Create function.
3. Configure the following settings:
    - Name – my-function.
    - Runtime – Node.js 16.x.
    - Role – Choose an existing role.
    - Existing role – lambda-role.
4. Choose Create function.
5. To configure a test event, choose Test.
6. For Event name, enter test.
7. Choose Save changes.
8. To invoke the function, choose Test.

The console creates a Lambda function with a single source file named index.js. You can edit this file and add more files in the built-in code editor. To save your changes, choose Save. Then, to run your code, choose Test.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/lambda-nodejs.md)

## AWS Lambda with AWS IoT

AWS IoT provides secure communication between internet-connected devices (such as sensors) and the AWS Cloud. This makes it possible for you to collect, store, and analyze telemetry data from multiple devices.

You can create AWS IoT rules for your devices to interact with AWS services. The AWS IoT Rules Engine provides a SQL-based language to select data from message payloads and send the data to other services, such as Amazon S3, Amazon DynamoDB, and AWS Lambda. You define a rule to invoke a Lambda function when you want to invoke another AWS service or a third-party service.

When an incoming IoT message triggers the rule, AWS IoT invokes your Lambda function asynchronously and passes data from the IoT message to the function.

[reference](https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/doc_source/services-iot.md)