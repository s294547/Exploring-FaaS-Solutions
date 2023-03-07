# OPENWHISK + MQTT

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Solution with a trigger service provider](#solution-with-a-trigger-service-provider)
	1. [Openwhisk packages](#openwhisk-packages)
	2. [Feeds on Openwhisk](#feeds-on-openwhisk)
	3. [Solution Implementation](#solution-implementation)
3. [Alternatives](#alternatives)
	1. [Trigger on changes for CouchDB](#trigger-on-changes-for-couchdb)
4. [References](#references)


## Introduction

In this file we will describe the possible alternatives to deliver data from IoT devices to Openwhisk Actions. The proposed solutions are all based on the MQTT protocol. 

## Solution with a trigger service provider

### Openwhisk packages

[reference](https://github.com/apache/openwhisk/blob/master/docs/packages.md)

In OpenWhisk, you can use packages to bundle together a set of related actions, and share them with others.

A package can include actions and feeds.

- An action is a piece of code that runs on OpenWhisk. For example, the Cloudant package includes actions to read and write records to a Cloudant database.
- A feed is used to configure an external event source to fire trigger events. For example, the Alarm package includes a feed that can fire a trigger at a specified frequency.

Every OpenWhisk entity, including packages, belongs in a namespace, and the fully qualified name of an entity is /namespaceName[/packageName]/entityName. Refer to the naming guidelines for more information.

### Feeds on Openwhisk

[reference](https://github.com/apache/openwhisk/blob/master/docs/feeds.md)

OpenWhisk supports an open API, where any user can expose an event producer service as a feed in a package. This section describes architectural and implementation options for providing your own feed.

#### **Difference between Feed and Trigger**
Feeds and triggers are closely related, but technically distinct concepts.

OpenWhisk processes events which flow into the system.

A **trigger** is technically a name for a class of events. Each event belongs to exactly one trigger; by analogy, a trigger resembles a topic in topic-based pub-sub systems. A rule T -> A means "whenever an event from trigger T arrives, invoke action A with the trigger payload".

A **feed** is a stream of events which all belong to some trigger T. A feed is controlled by a feed action which handles creating, deleting, pausing, and resuming the stream of events which comprise a feed. The feed action typically interacts with external services which produce the events, via a REST API that manages notifications.

#### **Implementing Feed Actions**
The feed action is a normal OpenWhisk action, but it should accept the following parameters:

- *lifecycleEvent*: one of 'CREATE', 'READ', 'UPDATE', 'DELETE', 'PAUSE', or 'UNPAUSE'.
- *triggerName*: the fully-qualified name of the trigger which contains events produced from this feed.
- *authKey*: the Basic auth credentials of the OpenWhisk user who owns the trigger just mentioned.
The feed action can also accept any other parameters it needs to manage the feed. For example the cloudant changes feed action expects to receive parameters including 'dbname', 'username', etc.

When the user creates a trigger from the CLI with the --feed parameter, the system automatically invokes the feed action with the appropriate parameters.

For example,assume the user has created a *mycloudant* binding for the cloudant package with their username and password as bound parameters. When the user issues the following command from the CLI:

```
wsk trigger create T --feed mycloudant/changes -p dbName myTable
```

then under the covers the system will do something equivalent to:

```
wsk action invoke mycloudant/changes -p lifecycleEvent CREATE -p triggerName T -p authKey <userAuthKey> -p password <password value from mycloudant binding> -p username <username value from mycloudant binding> -p dbName mytype
```

The feed action named changes takes these parameters, and is expected to take whatever action is necessary to set up a stream of events from Cloudant, with the appropriate configuration, directed to the trigger T.


A similar feed action protocol occurs for *wsk trigger delete*, *wsk trigger update* and *wsk trigger get*.

### Solution Implementation

We will therefore describe how we built a sample MQTT-based application that shows OpenWhisk in action for sensor data processing for future Internet of Things and smart dust scenarios.

The basic idea of the application is that it consumes data from an MQTT feed, stores it in a database and provides a means to access the database via a web UI. The architecture of the application is shown in the figure below.   

[application-architecture](./mqtt.png)

As can be seen from the figure, the motion sensor publishes messages to a specific topic. The trigger service provider subscribes to the same topic and fires OpenWhisk triggers that invoke the action *addReadingToDb* that inserts each message to a CouchDB database.

The IoT motion sensor and the MQTT broker were provided by our friends at the Cloud Accounting and Billing Initiative and were simply based on a Raspberry Pi with an attached motion sensor publishing to an MQTT broker. The motion sensor publishes a message to a specific topic ( *lexxito* in this case) every time it detects motion. The simple message contains a JSON object with just two keys: time and status.

We needed a persistent service that managed subscriptions from OpenWhisk trigger creations to topics and fired a trigger every time a new message was received. We used the service provider from the blog post mentioned above. However, we had to make some modifications to it as it assumed  Cloudant – the IBM proprietary data store – as a backend. As we are using vanilla OpenWhisk, we needed an alternative and we decided to use CouchDB instead. The modified code can be found [here](https://github.com/mohammed-ali-1/openwhisk_mqtt_feed).

We then deployed a CouchDB instance on our Kubernetes cluster in a separate namespace using the Helm package manager following these instructions. Next, we had to configure the CouchDB database so that it can be used by the service provider. To do that, we created a database in our CouchDB instance with the name *topic_listeners* by running the following:

```
$ curl -X PUT "http://username:password@COUCHDB_HOST:COUCHDB_PORT/topic_listeners"
```
This call returns the very informative response:

```
{"ok":true}
```
Which indicates that the configuration of the database was successful.

Then, we needed to add some views to our database. Views in CouchDB are used to query and filter documents. We created a file called views.json and added it to CouchDB by running the following command:

```
$ curl -X PUT "http://username:password@COUCHDB_HOST:COUCHDB_PORT/topic_listeners/_design/subscriptions" --data-binary @views.json
```

We had to create the readings database that will be used by the *addReadingToDb* action on CouchDB by running the following command:

```
$ curl -X PUT "http://username:password@COUCHDB_HOST:COUCHDB_PORT/readings"
```
Then, we were ready to deploy the service provider on our Kubernetes cluster by containerizing it first using the provided Dockerfile, pushing the docker container to Docker Hub, and then creating a deployment.yaml file for it.

Then, we deployed the service provider by running:

```
$ kubectl apply -f deployment.yaml
```
And to expose the pod as a service, we ran:

```
$ kubectl expose pod mqtt-provider --port='3000' --type='NodePort'
```

With that, the service provider was now ready to accept trigger registrations.

We then turned our attention to configuring OpenWhisk to connect to the service provider in order to register triggers with it. To do that, we created a shared package under the /whisk.system namespace to make it accessible to all users, with the name mqtt by running the following:

```

$ wsk package create \
--shared yes \
-p provider_endpoint "http://SERVICE_PROVIDER_HOST:SERVICE_PROVIDER_NODEPORT/mqtt" mqtt
```

And we added some description to the package:

```

$ wsk package update mqtt \
-a description 'The mqtt package provides functionality to connect to MQTT brokers'
```

Next, we created a feed action and associated it with the mqtt package. A feed action is an action that manages the lifecycle of triggers.

The feed action will take care of creating and removing triggers. This means that when a user would like to create a trigger, i.e. subscribe to a specific topic on an MQTT broker and fire triggers whenever a new message is published on the topic, the feed action will send a request to the service provider in order to register the trigger with the specific topic on the MQTT broker.

We added the feed action to the mqtt package by running the following command:

```

$ wsk action create -a feed true mqtt/mqtt_feed feed_action.js
```

Once we had the feed action configured, we were able to associate a trigger with the lexxito topic on the MQTT broker. To do that, we ran the following command:

```

$ wsk trigger create /guest/feed_trigger \
--feed /whisk.system/mqtt/mqtt_feed \
-p topic 'lexxito' \
-p url 'mqtt://mqtt.demonstrator.info' \
-p authKey $WHISK_GUEST_AUTH \
-p triggerName '/guest/feed_trigger'
```


Next, we created the action *addReadingToDb* that will insert each message to the CouchDB database. The code for the action can be viewed here.

The *addReadingToDb* action is a NodeJS package that used the sync-request NPM module to perform a POST request to the readings database on CouchDB. This was achieved by following the instructions from this blog post on how to package NPM dependencies for OpenWhisk actions.

Next, we added the *AddReadingToDb* action to OpenWhisk by running the following command:

```

$ wsk action create addReadingToDb \
--kind nodejs:default addReadingToDb.zip
```

Next, we had to create an OpenWhisk rule that connected the *feed_trigger* to the *addReadingToDbé action so that every time the *feed_trigger* is fired, the *addReadingToDb* action gets invoked. An OpenWhisk rule associates a trigger with an action, invoking the action when the associated trigger is fired.

To create the rule, we ran the following:

```
$ wsk rule create mqttRule /guest/feed_trigger addReadingToDb
```

Now every time a new message is published on the topic *lexxito*, a trigger is fired by the trigger service provider carrying with it the contents of the message to the *addReadingToDb* action. The action will then be invoked and will add the contents of the message to the readings database.

## Alternatives

An alternative may be (if we can control the broker) to configure the broker to fire an OpenWhisk trigger, without having to create a Trigger Service Porvider, which is subscribed to the interested topics and fires the triggers when a message is published in the topic. 

Another alternative may be to have another instance of CouchDB and to write all the published data here. We can associate to it a trigger that detects all the changes in the db. 

### Trigger on changes for CouchDB
[reference](https://github.com/apache/openwhisk-package-cloudant)

The */whisk.system/cloudant* package enables you to work with a Cloudant database. It includes the following actions and feeds.
|:---:|:---:|:---:|:---:|
|Entity|Type|Parameters|Description|
|/whisk.system/cloudant|	package|	dbname, host, username, password	|Work with a Cloudant database|
|/whisk.system/cloudant/read|action|dbname, id|	Read a document from a database|
|/whisk.system/cloudant/write|	action	|dbname, overwrite, doc|	Write a document to a database|
|/whisk.system/cloudant/changes|	feed	|dbname, iamApiKey, iamUrl, filter, query_params, maxTriggers|	Fire trigger events on changes to a database|

#### **Firing a trigger on database changes**
Use the changes feed to configure a service to fire a trigger on every change to your Cloudant database. The parameters are as follows:

1. *dbname* (required): The name of the Cloudant database.
2. *iamApiKey* (optional): The IAM API key for the Cloudant database. If specified will be used as the credentials instead of username and password.
3. *iamUrl* (optional): The IAM token service url that is used when iamApiKey is specified. Defaults to https://iam.bluemix.net/identity/token.
4. *maxTriggers* (optional): Stop firing triggers when this limit is reached. Defaults to infinite.
5. *filter* (optional): Filter function that is defined on a design document.
6. *query_params* (optional): Extra query parameters for the filter function.

#### **Using CouchDB**
CouchDB databases are compatible with this package but you need to ensure the CouchDB works via HTTPS and runs on the standard HTTP ports.

The simplest way to do this is to place a reverse proxy infront of the CouchDB server and then place a signed SSL certificate on it via a standard provider or a free service like LetsEncrypt.

#### **Listening for changes to a Cloudant database**
**Filter database change events**
You can define a filter function, to avoid having unnecessary change events firing your trigger.
To create a new filter function you can use an action.

Create a json document file design_doc.json with the following filter function

```
{
  "doc": {
    "_id": "_design/mailbox",
    "filters": {
      "by_status": "function(doc, req){if (doc.status != req.query.status){return false;} return true;}"
    }
  }
}
```

Create a new design document on the database with the filter function
```
wsk action invoke /_/myCloudant/write -p dbname testdb -p overwrite true -P design_doc.json -r
```
The information for the new design document is printed on the screen.

```
{
    "id": "_design/mailbox",
    "ok": true,
    "rev": "1-5c361ed5141bc7856d4d7c24e4daddfd"
}
```

**Create the trigger using the filter function**
You can use the changes feed to configure a service to fire a trigger on every change to your Cloudant database. The parameters are as follows:

- *dbname*: Name of Cloudant database.
- *maxTriggers*: Stop firing triggers when this limit is reached. Defaults to infinite.
- *filter*: Filter function defined on a design document.
- *query_params*: Optional query parameters for the filter function.

Create a trigger with the changes feed in the package binding that you created previously including *filter* and *query_params* to only fire the trigger when a document is added or modified when the status is new. Be sure to replace */_/myCloudant* with your package name.
```
wsk trigger create myCloudantTrigger --feed /_/myCloudant/changes \
--param dbname testdb \
--param filter "mailbox/by_status" \
--param query_params '{"status":"new"}'
ok: created trigger feed myCloudantTrigger
```
Poll for activations.
```
wsk activation poll
```
In your Cloudant dashboard, either modify an existing document or create a new one.

Observe new activations for the myCloudantTrigger trigger for each document change only if the document status is new based on the filter function and query parameter.

Note: If you are unable to observe new activations, see the subsequent sections on reading from and writing to a Cloudant database. Testing the following reading and writing steps will help verify that your Cloudant credentials are correct.

You can now create rules and associate them to actions to react to the document updates.

The content of the generated events has the following parameters:

- *id*: The document ID.
- *seq*: The sequence identifier that is generated by Cloudant.
- *changes*: An array of objects, each of which has a rev field that contains the revision ID of the document.
The JSON representation of the trigger event is as follows:

```
{
    "id": "6ca436c44074c4c2aa6a40c9a188b348",
    "seq": "2-g1AAAAL9aJyV-GJCaEuqx4-BktQkYp_dmIfC",
    "changes": [
        {
            "rev": "2-da3f80848a480379486fb4a2ad98fa16"
        }
    ]
}
```


## References

1. [Code](https://github.com/mohammed-ali-1/openwhisk_mqtt_feed)
2. [Article](https://blog.zhaw.ch/splab/2019/03/15/building-a-sample-mqtt-based-application-on-openwhisk/)
3. [Article](https://www.fiware.org/wp-content/uploads/2017/01/The-next-trend-in-application-development.-serveless-apps.pdf)
4. [Openwhisk Packages](https://github.com/apache/openwhisk/blob/master/docs/packages.md#browsing-packages)
5. [Openwhisk Feeds](https://github.com/apache/openwhisk/blob/master/docs/feeds.md)