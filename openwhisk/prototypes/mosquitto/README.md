# Deploying a Mosquitto MQTT Broker + publisher example +subscriber example

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Deploying Mosquitto](#deploying-mosquitto)
	1. [How to create credentials for your mqtt broker](#how-to-create-credentials-for-your-mqtt-broker)
	2. [Deploy the MQTT broker](#deploy-the-mqtt-broker)
3. [Create the publisher and  subscriber pods](#create-the-publisher-and-subscriber-pods)

## Introduction
In this file I am going to show all the steps provided to deploy a mosquitto MQTT broker on my kuberneets cluster and to create two pods running an example of publisher and subscriber. We will find all the related data in the folders [mosquitto](./mosquitto/), [publisher](./publisher/) and [subscriber](./subscriber).

Since this thesis is focused on the field of fog computing, we can assume that this steps have to be replicated for each cluster: each cluster will have its own MQTT broker, and all the sensors in this data center will publish their data to it. 

Since the usage of the MQTT broker will be limited inside the cluster, the version of the MQTT protocol is the basic one, not the one over TLS/SSL. 

All the informations related to how implement the trigger that is fired when a new message is published on a given topic will be in the folder [openwhisk_mqtt_feed](./openwhisk_mqtt_feed/).


## Deploying Mosquitto

To perform the needed operations you must be inside the *mosquitto* folder.

### How to create credentials for your mqtt broker

The following command can be used to create a new username + password, hashed in a file called test.txt
```
sudo mosquitto_passwd -c test.txt <username>
```
In the example of our repository, we create a username and a password test:test.
The result was:
```
test:$6$WgoRASWRnPePPq4Q$Q6g58x1Gf2mcoC/H1hOlm3Zml2dPyKGhqrmtU8fjjLr1/20Ddi+lm46zp4fqO+wgquXp8QHJLq/gW54h+KU7dw==
```
All credentials have to be injected into the configmap, provided in the repository.
You can just list all your credential pairs.

### Deploy the MQTT broker
First, change everywhere the namespace to an appropiate one.
Then, change in the service.yaml the NodePort that you want to expose.
Afterwards create all ressources via 
```
kubectl apply -f .yaml
```
## Create the publisher and  subscriber pods

When creating the subscriber, you must place yourself in the *subscriber* folder, otherwise you should place yourself in the *publisher* folder.

For the the publisher, you should execute those commands:

```
export MASTER_IP=38.242.158.232
docker build --build-arg masster_ip=$MASTER_IP -f Dockerfile -t publisher:latest .
docker tag publisher:latest giuliabianchi1408/publisher:latest
docker push giuliabianchi1408/publisher:latest
kubectl apply -f deployment.yaml -n mosquitto
```

The *MASTER_IP* is the IP Address of the master node of the kubernetes cluster where the solution is going to be deployed. I have created a repository *publisher* on dockerhub. 

