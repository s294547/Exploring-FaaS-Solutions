# DISCOVERING AND COMPARING FaaS TOOLS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [What is Faas](#what-is-faas)
	1. [Limtations](#limitations)
2. [IoT and FaaS](#iot-and-faas)
	1. [OpenFaas](#openfaas)
	2. [OpenWhisk](#openwhisk)
3. [Supported Languages](#supported-languages)
	1. [OpenFaas](#openfaas-1)
	2. [OpenWhisk](#openwhisk-1)
4. [Creating a Function](#creating-a-function)
	1. [OpenFaas](#openfaas-2)
	2. [OpenWhisk](#openwhisk-2)
5. [The cost of running a function and possible optimizations](#the-cost-of-running-a-function-and-possible-optimizations)
	1. [OpenFaas](#openfaas-3)
	2. [OpenWhisk](#openwhisk-3)
6. [Running Functions](#running-functions)
7. [Summary Matrix](#summary-matrix)
8. [Resources](#resources)


## What is FaaS

FaaS is about running backend code without managing your own server systems or your own long-lived server applications. That second clause—long-lived server applications—is a key difference when comparing with other modern architectural trends like containers and PaaS (Platform as a Service).

FaaS offerings do not require coding to a specific framework or library. FaaS functions are regular applications when it comes to language and environment. For instance, AWS Lambda functions can be implemented “first class” in Javascript, Python, Go, any JVM language (Java, Clojure, Scala, etc.), or any .NET language. However your Lambda function can also execute another process that is bundled with its deployment artifact, so you can actually use any language that can compile down to a Unix process (see Apex, later in this article).

Deployment is very different from traditional systems since we have no server applications to run ourselves. In a FaaS environment we upload the code for our function to the FaaS provider, and the provider does everything else necessary for provisioning resources, instantiating VMs, managing processes, etc.

**Horizontal scaling is completely automatic, elastic, and managed by the provider.** If your system needs to be processing 100 requests in parallel the provider will handle that without any extra configuration on your part. The “compute containers” executing your functions are ephemeral, with the FaaS provider creating and destroying them purely driven by runtime need. Most importantly, with FaaS the vendor handles all underlying resource provisioning and allocation—no cluster or VM management is required by the user at all.

Functions in FaaS are typically triggered by event types defined by the provider. With Amazon AWS such stimuli include S3 (file/object) updates, time (scheduled tasks), and messages added to a message bus (e.g., Kinesis).

Most providers also allow functions to be triggered as a response to inbound HTTP requests; in AWS one typically enables this by way of using an API gateway.

### Limitations

#### State

FaaS functions have significant restrictions when it comes to local (machine/instance-bound) state—i.e., data that you store in variables in memory, or data that you write to local disk. You do have such storage available, but you have no guarantee that such state is persisted across multiple invocations, and, more strongly, you should not assume that state from one invocation of a function will be available to another invocation of the same function. FaaS functions are therefore often described as stateless, but it’s more accurate to say that any state of a FaaS function that is required to be persistent needs to be externalized outside of the FaaS function instance.

#### Execution Duration

FaaS functions are typically limited in how long each invocation is allowed to run. At present the “timeout” for an AWS Lambda function to respond to an event is at most five minutes, before being terminated. Microsoft Azure and Google Cloud Functions have similar limits.

This means that certain classes of long-lived tasks are not suited to FaaS functions without re-architecture—you may need to create several different coordinated FaaS functions, whereas in a traditional environment you may have one long-duration task performing both coordination and execution.

#### Startup latency and “cold starts”
It takes some time for a FaaS platform to initialize an instance of a function before each event. This startup latency can vary significantly, even for one specific function, depending on a large number of factors, and may range anywhere from a few milliseconds to several seconds. That sounds bad, but let’s get a little more specific, using AWS Lambda as an example.

Initialization of a Lambda function will either be a “warm start”—reusing an instance of a Lambda function and its host container from a previous event—or a “cold start” —creating a new container instance, starting the function host process, etc. Unsurprisingly, when considering startup latency, it’s these cold starts that bring the most concern.

Cold-start latency depends on many variables: the language you use, how many libraries you’re using, how much code you have, the configuration of the Lambda function environment itself, whether you need to connect to VPC resources, etc. Many of these aspects are under a developer’s control, so it’s often possible to reduce the startup latency incurred as part of a cold start.

Equally as variable as cold-start duration is cold-start frequency. For instance, if a function is processing 10 events per second, with each event taking 50 ms to process, you’ll likely only see a cold start with Lambda every 100,000–200,000 events or so. If, on the other hand, you process an event once per hour, you’ll likely see a cold start for every event, since Amazon retires inactive Lambda instances after a few minutes. Knowing this will help you understand whether cold starts will impact you on aggregate, and whether you might want to perform “keep alives” of your function instances to avoid them being put out to pasture.

#### Comparison with PaaS

**Given that Serverless FaaS functions are very similar to Twelve-Factor applications, are they just another form of "Platform as a Service" (PaaS)?**

Most PaaS applications are not geared towards bringing entire applications up and down in response to an event, whereas FaaS platforms do exactly this.

The key operational difference between FaaS and PaaS is scaling. Generally with a PaaS you still need to think about how to scale—for example, with Heroku, how many Dynos do you want to run? With a FaaS application this is completely transparent. Even if you set up your PaaS application to auto-scale you won’t be doing this to the level of individual requests (unless you have a very specifically shaped traffic profile), so a FaaS application is much more efficient when it comes to costs.

## IoT and FaaS

### OpenFaaS

### OpenWhisk

Internet of Things scenarios are often inherently sensor-driven. For example, an action in OpenWhisk might be triggered if there is a need to react to a sensor that is exceeding a particular temperature. IoT interactions are usually stateless with potential for very high level of load in case of major events (natural disasters, significant weather events, traffic jams, etc.) This creates a need for an elastic system where normal workload might be small, but needs to scale very quickly with predictable response time and ability to handle extremely large number of events with no prior warning to the system. It is very hard to build a system to meet these requirements using traditional server architectures as they tend to either be underpowered and unable to handle peak in traffic or be over-provisioned and extremely expensive.

## Supported Languages

### OpenFaaS
Functions can be written in any language, and are built into portable OCI images.

We have official templates available for: Go, Java, Python, C#, Ruby, Node.js, PHP, or you can write your own.

So, functions can be created with any language if using a dockerfile.

### OpenWhisk
Actions can be small snippets of code (JavaScript, Swift and many other languages are supported), or custom binary code embedded in a Docker container.
The following is a list of runtimes the Apache OpenWhisk project has officially released:
**.Net** - OpenWhisk runtime for .Net Core 2.2
**Go** - OpenWhisk runtime for Go
**Java** - OpenWhisk runtime for Java 8 (OpenJDK 8, JVM OpenJ9)
**JavaScript** - OpenWhisk runtime for Node.js v10, v12 and v14
**PHP** - OpenWhisk runtime for PHP 8.0, 7.4 and 7.3
**Python** - OpenWhisk runtime for Python 2.7, 3 and a 3 runtime variant for AI/ML (including packages for Tensorflow and PyTorch)
**Ruby** - OpenWhisk runtime for Ruby 2.5
**Swift** - OpenWhisk runtime for Swift 3.1.1, 4.1 and 4.2

If you need languages or libraries the current "out-of-the-box" runtimes do not support, you can create and customize your own executable that run "black box" Docker Actions using the Docker SDK which are run on the Docker Runtime.

## Creating a Function
### OpenFaaS
#### Building Images
![dev-workflow-2000-opt](./openfaas/dev-workflow-2000-opt.png)
Openfaas functions run in containers, someone (or something) needs to build images for these containers. And like it or not, the responsibility lies on developers. OpenFaaS provides a handy faas-cli build command but no server-side builds. So, you either need to run faas-cli build manually (from a machine running Docker) or teach your CI/CD how to do it.

Built images then need to be pushed with faas-cli push to a registry. Obviously, such a registry should be reachable from the OpenFaaS server-side as well. Otherwise, trying to deploy a function with faas-cli deploy will fail.

#### Watchdog
OpenFaaS functions are run in containers, and every such container must conform to a simple convention - it must act as an HTTP server listening on a predefined port (8080 by default), assume ephemeral storage, and be stateless.

However, OpenFaaS offloads the need to write such servers from users through the function watchdog pattern. A function watchdog is a lightweight HTTP server with the knowledge on how to execute the actual function's business logic. So, everything installed in a container plus such a watchdog as its entrypoint will constitute the function's runtime environment.

##### Classic WatchDog
![classic-watchdog-2000-opt](./openfaas/classic-watchdog-2000-opt.png)

##### Reverse Proxy Watchdog
![reverse-proxy-watchdog-2000-opt](./openfaas/reverse-proxy-watchdog-2000-opt.png)

#### Resources created i kubernetes
When using Kubernetes, each function you deploy through the OpenFaaS API **will create a separate Kubernetes Deployment object**. Deployment objects have a "replicas" value which corresponds to the number of Pods created in the cluster, that can serve traffic for your function.

A Kubernetes Service object is also created and is used to access the function's HTTP endpoint on port 80, within the cluster.

To see the resources created, you can type in:

faas-cli store deploy cows
kubectl get -n openfaas-fn service/cows -o yaml
kubectl get -n openfaas-fn deploy/cows -o yaml
By default, all functions have a minimum of 1 replica set through auto-scaling labels, this can prevent a so called "cold-start", where a deployment is set to 0 replicas, and a Pod needs to be created to serve an incoming request.

**The Scale to Zero functionality of OpenFaaS Pro can be used to scale idle functions down to 0 replicas, to save on resources.**

### OpenWhisk
#### Creation of an Action
To give the explanation a little bit of context, let’s create an action in the system first. We will use that action to explain the concepts later on while tracing through the system. The following commands assume that the OpenWhisk CLI is setup properly.

First, we’ll create a file action.js containing the following code which will print “Hello World” to stdout and return a JSON object containing “world” under the key “hello”.

```
function main() {
    console.log('Hello World');
    return { hello: 'world' };
}
```
We create that action using.

```
wsk action create myAction action.js
```
Done. Now we actually want to invoke that action:

```
wsk action invoke myAction --result
```

#### The internal flow of processing

![openwhisk-flow-of-processing](./openwhisk/OpenWhisk_flow_of_processing.png)

##### Entering the system: nginx
First: OpenWhisk’s user-facing API is completely HTTP based and follows a RESTful design. As a consequence, the command sent via the wsk CLI is essentially an HTTP request against the OpenWhisk system. The specific command above translates roughly to:

```
POST /api/v1/namespaces/$userNamespace/actions/myAction
Host: $openwhiskEndpoint
```
Note the $userNamespace variable here. A user has access to at least one namespace. For simplicity, let’s assume that the user owns the namespace where myAction is put into.

The first entry point into the system is through nginx, “an HTTP and reverse proxy server”. It is mainly used for SSL termination and forwarding appropriate HTTP calls to the next component.

##### Entering the system: Controller

Not having done much to our HTTP request, nginx forwards it to the Controller, the next component on our trip through OpenWhisk. It is a Scala-based implementation of the actual REST API (based on Akka and Spray) and thus serves as the interface for everything a user can do, including CRUD requests for your entities in OpenWhisk and invocation of actions (which is what we’re doing right now).

The Controller first disambiguates what the user is trying to do. It does so based on the HTTP method you use in your HTTP request. As per translation above, the user is issuing a POST request to an existing action, which the Controller translates to an invocation of an action.

Given the central role of the Controller (hence the name), the following steps will all involve it to a certain extent.

##### Authentication and Authorization: CouchDB

Now the Controller verifies who you are (Authentication) and if you have the privilege to do what you want to do with that entity (Authorization). The credentials included in the request are verified against the so-called subjects database in a CouchDB instance.

In this case, it is checked that the user exists in OpenWhisk’s database and that it has the privilege to invoke the action myAction, which we assumed is an action in a namespace the user owns. The latter effectively gives the user the privilege to invoke the action, which is what he wishes to do.

As everything is sound, the gate opens for the next stage of processing.

##### Getting the action: CouchDB… again

As the Controller is now sure the user is allowed in and has the privileges to invoke his action, it actually loads this action (in this case myAction) from the whisks database in CouchDB.

The record of the action contains mainly the code to execute (shown above) and default parameters that you want to pass to your action, merged with the parameters you included in the actual invoke request. It also contains the resource restrictions imposed on it in execution, such as the memory it is allowed to consume.

In this particular case, our action doesn’t take any parameters (the function’s parameter definition is an empty list), thus we assume we haven’t set any default parameters and haven’t sent any specific parameters to the action, making for the most trivial case from this point-of-view.

##### Who’s there to invoke the action: Load Balancer

The Load Balancer, which is part of the Controller, has a global view of the executors available in the system by checking their health status continuously. Those executors are called Invokers. The Load Balancer, knowing which Invokers are available, chooses one of them to invoke the action requested.

##### Please form a line: Kafka

From now on, mainly two bad things can happen to the invocation request you sent in:

1. The system can crash, losing your invocation.
2. The system can be under such a heavy load, that the invocation needs to wait for other invocations to finish first.
The answer to both is Kafka, “a high-throughput, distributed, publish-subscribe messaging system”. Controller and Invoker solely communicate through messages buffered and persisted by Kafka. That lifts the burden of buffering in memory, risking an OutOfMemoryException, off of both the Controller and the Invoker while also making sure that messages are not lost in case the system crashes.

To get the action invoked then, the Controller publishes a message to Kafka, which contains the action to invoke and the parameters to pass to that action (in this case none). This message is addressed to the Invoker which the Controller chose above from the list of available invokers.

Once Kafka has confirmed that it got the message, the HTTP request to the user is responded to with an ActivationId. The user will use that later on, to get access to the results of this specific invocation. Note that this is an asynchronous invocation model, where the HTTP request terminates once the system has accepted the request to invoke an action. A synchronous model (called blocking invocation) is available, but not covered by this article.

##### Actually invoking the code already: Invoker
The Invoker is the heart of OpenWhisk. The Invoker’s duty is to invoke an action. It is also implemented in Scala. But there’s much more to it. To execute actions in an isolated and safe way it uses Docker.

**Docker is used to setup a new self-encapsulated environment (called container) for each action that we invoke in a fast, isolated and controlled way. In a nutshell, for each action invocation a Docker container is spawned, the action code gets injected, it gets executed using the parameters passed to it, the result is obtained, the container gets destroyed. This is also the place where a lot of performance optimization is done to reduce overhead and make low response times possible.**

In our specific case, as we’re having a Node.js based action at hand, the Invoker will start a Node.js container, inject the code from myAction, run it with no parameters, extract the result, save the logs and destroy the Node.js container again.

##### Storing the results: CouchDB again

As the result is obtained by the Invoker, it is stored into the activations database as an activation under the ActivationId mentioned further above. The activations database lives in CouchDB.

In our specific case, the Invoker gets the resulting JSON object back from the action, grabs the log written by Docker, puts them all into the activation record and stores it into the database. It will look roughly like this:

```
{
   "activationId": "31809ddca6f64cfc9de2937ebd44fbb9",
   "response": {
       "statusCode": 0,
       "result": {
           "hello": "world"
       }
   },
   "end": 1474459415621,
   "logs": [
       "2016-09-21T12:03:35.619234386Z stdout: Hello World"
   ],
   "start": 1474459415595,
}
```
Note how the record contains both the returned result and the logs written. It also contains the start and end time of the invocation of the action. There are more fields in an activation record, this is a stripped down version for simplicity.

Now you can use the REST API again (start from step 1 again) to obtain your activation and thus the result of your action. To do so you’d use:
```
wsk activation get 31809ddca6f64cfc9de2937ebd44fbb9
```

## The cost of running a function and possible optimizations

### OpenFaaS
Let’s look at the lifecycle of a container, or as I like to call it “Why is this thing so slow?”

There’s several things that happen when a container is scheduled on Kubernetes:

1.The container image has to be fetched from a remote registry
2.The container has to be scheduled on a node with available resources
3.The container has to be started and have its endpoint registered for health checks
4.A health check has to pass for the container’s endpoint
And when all that’s complete, you can probably serve a request.


So I tried it out, and found that this process would take several seconds, even for small container images, or images that were already cached on my cluster.

Why was that? Primarily because the health checks in Kubernetes at a minimum of every 1 second, so if you miss the first, you have to wait for the second to pass. Thus you get your 2 second latency for a cold-start.

Container should be created at deployment time, and perhaps we should use process-level isolation instead, so we add a Watchdog in each contianer. The OpenFaaS watchdog creates a process per request.

To re-use the same process instead,  the of-watchdog was created and added HTTP-level multiplexing for requests.


Scaling up from zero replicas or 0/0 can be toggled through the scale_from_zero environment variable for the OpenFaaS Gateway. This is turned on by default on Kubernetes and faasd.

The latency between accepting a request for an unavailable function and serving the request is sometimes called a "Cold Start".

**What if I don't want a "cold start"?**

The cold start in OpenFaaS is strictly optional and it is recommended that for time-sensitive operations you avoid one by having a minimum scale of 1 or more replicas. This can be achieved by not scaling critical functions down to zero replicas, or by invoking them through the asynchronous route which decouples the request time from the caller.


### OpenWhisk

The Invoker is arguably the heart of OpenWhisk. It’s responsible for making sure your code actually runs. Its also the component which produces by far the most overhead in the system, latency-wise.

As the architecture chart indicates, the Invoker works by talking to docker. We use docker to containerize each action to be able to provide multi-tenant execution where different users do not impact each other. Containers give a convenient mechanism to “blindly” run untrusted code while having the tools at hand to prevent this code from doing bad things.

Inside those containers, OpenWhisk uses a small HTTP server to provide two endpoints, /init and /run. Those endpoints inject the action code into the container and run it respectively. /init takes the action’s code and does whatever is necessary to make this code a runnable entity. In Node.js the code is simply interpreted, but Swift for example even compiles the code. You get the idea. It’s also clear now: Initializing a container can come at a cost! After initialization was successful, /run is used to pass arguments to the action and execute it.

The critical path for a container involves the following steps:

1. Starting the container via docker run. As we’re doing HTTP calls to that container, we also get the container’s IP address via docker inspect.
2. Initializing the container with the action that was given by the user via /init.
3. Run the action via /run.
If you need to go through all those steps, we speak of a cold container.

In the grand total, to perfrom an action we need to do:

1. 2 docker commands: docker run and docker inspect. The former alone takes around 300 milliseconds to do its job.
2. 2 HTTP calls: /init and /run. The latency of initialization highly depends on the runtime used and the amount of code you want to run. The latency of running the code itself is determined by the task at hand.
3. 2 Kafka messages: the “job” message and the response message. They usually add less than 5 milliseconds of latency.
4. 3 database calls: authentication, get the action in the controller, get the action in the invoker. The latency here depends on where you host the database and how large the entities are of course.

Let’s see how we can optimize the overhead away, step by step.

**Good old caching**
To reduce the overhead of database calls we use in-memory caching. That’s all. At a steady state and if you bring a lot of load to the system there won’t be any call to a database on your critical path. By using caches we completely take the database out of the game.

**Container reuse**

One of the most obvious mechanisms to reduce the overhead is to completely take the containerization system out of the game. In this case, that means again: caching. Or container-reuse. If a user fires the same action twice, and the first action has already finished, we can just use the same container again. Per the steps mentioned above, that will spare us the docker run and the HTTP call to initialize the action. In OpenWhisk we call this a warm container. Warm containers are the best you can get in terms of latency and throughput. The more load you impose on the system, the more warm containers you will have.

Doing the math, for a warm invocation we completely avoid the docker commands needed to start a container as it already exists. The /init call vanishes as well. We’re left with 1 HTTP call (/run) and our 2 Kafka messages on the critical path. That’s as close to your application latency (determined by /run) as it gets.

**Container prewarming**

Warm containers do not solve the “cold-start” latency problem though. That is the effect of the very first invocation of an action taking awfully long. To address this, OpenWhisk spawns so-called prewarmed containers. For example, let’s assume that the majority of all requests use Node.js based actions. As a consequence, OpenWhisk can spawns some Node.js containers, anticipating user load.

That has the effect of reducing cold-start latency by quite a bit as it eliminates the most expensive operation we have (docker run) and takes it off the critical path. That leaves us with 2 HTTP calls (/init and /run) plus the 2 Kafka messages on the critical path for an invocation using a prewarmed container.

## Running Functions

### OpenFaaS

When a function is deployed, you can invoke it by sending a GET, POST, PUT, or DELETE HTTP request to an endpoint like $API_HOST:$API_PORT/function/<fn-name>. The most common ways to call a function are:

1. various webhooks
2. faas-cli invoke
3. event connectors!

The first two options are rather straightforward. It's handy to use functions as ad-hoc webhooks handlers (GitHub, IFTTT, etc.), and every function developer already has faas-cli installed, so it can become an integral part of day-to-day scripting.

But what is an event connector?
OpenFaaS offers a universal solution called Event Connector Pattern.


There is a bunch of officially supported connectors:

Cron connector
MQTT connector
NATS connector
Kafka connector (Pro subscription required)
And OpenFaaS also has a tiny connector-sdk library to ease the development of new connectors.

### OpenWhisk

In openwhisk, you can both invoke an action from the cli or it may be invoked because a trigger associated with a rule to the action is fired.

## Summary Matrix

||**OpenFaaS**|**OpenWhisk**|
|:----------: |:----------: |:----------: |
| **Supported Languages** | Any with dockerfiles|Any with dockerfiles|
| **Containers associated to a newly created function** | At least one (0 with Scale to Zero functionality enabled) |0, containers are created when an action is invoked|
| **Container reuse to avoid cold start** | Yes | Yes, but if there is small number/time distance between requests containers are usually killed and recreated when needed|

## Resources

https://martinfowler.com/articles/serverless.html
https://medium.com/openwhisk/squeezing-the-milliseconds-how-to-make-serverless-platforms-blazing-fast-aea0e9951bd0
https://github.com/apache/openwhisk/tree/master/docs


https://iximiuz.com/en/posts/openfaas-case-study/
file:///C:/Users/yukik/Downloads/Open_Source_FaaS_Performance_Aspects.pdf
https://docs.openfaas.com/cli/templates/
https://karthi-net.medium.com/openfaas-tutorial-build-and-deploy-serverless-java-functions-bcf4e08c3a28
https://docs.openfaas.com/openfaas-pro/scale-to-zero/
https://www.openfaas.com/blog/kafka-connector/