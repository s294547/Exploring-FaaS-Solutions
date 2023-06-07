# OPENWHISK - ACTIONS AND TRIGGERS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [views.json](#views.json)


## Introduction


In this folder, you will find:
1. [actions-and-triggers]: the actions implemented on the OpenWhisk instance.
2. [views.json]: a JSON document that defines views for a CouchDB database

## Views.json

This folder contains a JSON document that defines views for a CouchDB database. The views are defined under the views property, and there are four of them:

1. *host_topic_counts*: This view emits the combination of the url and topic properties of a document as the key, and a value of 1. The view is intended to be used with the _sum reduce function to count the number of documents that have the same url and topic.

2. *host_topic_triggers*: This view emits the combination of the url and topic properties of a document as the key, and an object containing the _id, username, and password properties of the document as the value. This view is intended to be used to look up the trigger for a given url and topic.

3. *all*: This view emits the _id property of a document as the key, and the combination of the url and topic properties of the document as the value. This view is intended to be used to list all of the url and topic combinations in the database.

4. *host_triggers*: This view emits the url property of a document as the key, and an object containing the _id, username, and password properties of the document as the value. This view is intended to be used to look up all of the triggers associated with a given url.