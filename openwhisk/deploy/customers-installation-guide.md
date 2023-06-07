# OPENWHISK - INSTALLATION GUIDE FOR CUSTOMERS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Required Tools](#required-tools)
	1. [Install yq](#install-yq)
	2. [Install helm](#install-helm)
	3. [Install traefik](#install-traefik)
3. [Edge Instance Deployment](#edge-instance-deployment)
	1. [Cluster Set Up](#cluster-set-up)
	2. [Sensors' Set Up](#sensors'-set-up)
	3. [Publishing on Other Topics](#publishing-on-other-topics)

## Introduction

This file contains the installation guide for customers of the solution based on OpenWhisk for edge clusters.


## Required Tools

To be able to deploy the centralized or the edge solution, the provided scripts will have to be executed on a linux machine/container/pod and the cluster must already have the following tools/resources:

- The KubeConfig file must be present and must refer to the cluster we are working on.
- *kubectl*
- helm
- yq 
- traefik

We assume that at least the Kubernetes configuration is already present in the cluster.


### Install yq

Here are the steps to follow to install yq:

```
sudo add-apt-repository ppa:rmescandon/yq
sudo apt-get install yq
```

If you place yourself in [this folder](./edge/install-tools/) you can also run:

```
./install-yq.sh
```

### Install helm

Here are the steps to follow to install helm:

```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

If you place yourself in [this folder](./edge/install-tools/) you can also run:

```
./install-helm.sh
```

### Install traefik

We must install traefik in our cluster if it is not present.

```
helm install traefik chartmuseum/traefik -n traefik --set global.domain_name=<cluster_domain_name> --set global.ipv4_address=<cluster_ipv4_address>
```

To get the <cluster_ipv4_address> you must run:
```
kubectl describe nodes | grep "InternalIP" | awk '{print $2}'
```

If you place yourself in [this folder](./edge/install-tools/) you can also run:

```
./install-traefik.sh
```


## Edge Instance Deployment

To have a correctly working system, we need to:
1. Set up the cluster with all the required tools and services (openwhisk, influxdb, ecc..)
2. Set up the sensors to properly collect data, connect to a Wi-Fi network and to communicate with the local mosquitto broker.


### Cluster Set Up

All the necessary data/files and tools to deploy the edge instance can be found in the folder *[edge](./edge/)*. 

To deploy the edge instance, we must run the script *[deploy.sh](./edge/deploy.sh)*. In particular, we must run the following command:

```
./deploy.sh <instance-namespace>
```

The suggested namespace name is <openwhisk>.
Inside the *[edge](./edge/)* folder, you will find a detailed explanation of the script and of all the other resources that are inside it.

### Sensors' Set Up

In the folder [./edge/sensors](./edge/sensors/) there are two different arduino projects to set up an ESP8266 sensor provided with a gas, humidity and temperature sensor.

First, when using sensors inside a data center, we'll need to run the code that writes in the EEPROM of the board the location ID, which will be sent together with the data to the MQTT broker. 

To do that, the local data center administrator should modify [this code](./edge/sensors/store_datacenterID_eeprom/), setting the variable *dataCenterID* with an unsigned integer that represents the data center  ID.

After that, before uploading the [code responsible for sending telemetry to the MQTT broker](./edge/sensors/send_telemetry/send_telemetry.ino), the local data center administrator should make some modifications on the following variables, to be sure that the solution works:

**ssid**: it should contain the value of the Wi-Fi SSID.
**password**: it should contain the value of the Wi-FI password.
**mqtt_broker**: the master node IP of the cluster (the one that is used to reach NodePort services).
**topic**: the mqtt topic name.
**mqtt_username**: the mqtt username, which can be found in [this file](./parameters/parameters.yml) with name *.mosquitto.username*.
**mqtt_password**: the mqtt password, which can be found in [this file](./parameters/parameters.yml) with name *.mosquitto.plainPassword*.
**mqtt_port**: the external NodePort on which the mosquitto service is exposed outside the cluster. 

It can be retrieved using:
```
kubectl get svc mosquitto -o=jsonpath='{.spec.ports[0].nodePort}' -n <release-namespace>
```

### Publishing on Other Topics

By default, the sensors publish data on the topic called *test* and the MQTT provider listens for messages that are published on that topic. If we want for some reason to change the code of the sensors and let them publish messages in another topic, we need to configure the local MQTT provider to listen on that topic. To do that, we must run the following command:

```
wsk trigger create /guest/<new_trigger_name> --feed /guest/mqtt/mqtt_feed -p topic '<topic-name>' -p url "http://<mosquittoUsername>:<mosquittoPassword>@<releaseName>-mosquitto:<mosquittoPort>" -p triggerName '/guest/feed_trigger' -i
wsk rule create <newRuleName> '/guest/<new_trigger_name>' addReadingToDb -i
```

