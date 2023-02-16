# OPENFAAS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Required Tools Installation](#required-tools-installation)
	1. [Install cosign](#install-cosign)
	2. [Install jq](#install-jq)
	3. [Verifying image signatures](#verifying-image-signatures)
3. [Deploy Knative Serving](#deploy-knative-serving)
	1. [Install networking layer](#install-networking-layer)
	2. [Verify the installation](#verify-the-installation)
	3. [Install DNS](#install-dns)
3. [Deploy Knative Eventing](#deploy-knative-eventing)
	1. [Verify the installation](#verify-the-installation)
	2. [Install a default Channel (messaging) layer](#install-a-default-channel-(messaging)-layer)
	3. [Install a Broker layer](#install-a-broker-layer)
4. [Install Knative Functions](#install-knative-functions)
4. [Create a function](#create-a-function)
5. [Invoke a function](#invoke-a-function)

## Introduction
This file will document all the steps required to deploy Knative Serving and eventing on a given Kubernetes Cluster.
This example was done using Docker Desktop on Windows 11 with Ubuntu 22 WSL 2. 
It will also be reported an example of how to create a function with Knative.

The repository up to now will just keep a *appfleet-hello-world-right.yaml* file and a directory *appfleet-hello-world-right* with the code of the Node.js function *appfleet-hello-world-right.js*.  

## Required Tools Installation

### Install Cosign

Install cosign.
```
wget "https://github.com/sigstore/cosign/releases/download/v1.6.0/cosign-linux-amd64"
mv cosign-linux-amd64 /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign
export PATH=$PATH:/usr/local/bin/cosign
```

### Install jq

Install jq

```
sudo apt update
sudo apt install -y jq
```

### Verifying image signatures

Knative releases from 1.9 onwards are signed with cosign.
1. Install cosign and jq.
2. Extract the images from a manifeset and verify the signatures.

```
curl -fsSLO https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-core.yaml
cat serving-core.yaml | grep 'gcr.io/' | awk '{print $2}' > images.txt
input=images.txt
while IFS= read -r image
do
  COSIGN_EXPERIMENTAL=1 cosign verify -o text "$image" | jq
done < "$input"
```

## Deploy Knative Serving

Install the required custom resources by running the command:
```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-crds.yaml
```

Install the core components of Knative Serving by running the command:
```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-core.yaml
```
### Install Networking Layer

Install the Knative Kourier controller by running the command:
```
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.9.0/kourier.yaml
```

Configure Knative Serving to use Kourier by default by running the command:
```
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
```

Fetch the External IP address or CNAME by running the command:
```
kubectl --namespace kourier-system get service kourier
```

### Verify the installation

Monitor the Knative components until all of the components show a STATUS of *Running* or *Completed*. You can do this by running the following command and inspecting the output:
```
kubectl get pods -n knative-serving
```

### Configure DNS

You can configure DNS to prevent the need to run curl commands with a host header.

Knative provides a Kubernetes Job called default-domain that configures Knative Serving to use sslip.io as the default DNS suffix.

```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-default-domain.yaml
```

## Install Knative Eventing
To install Knative Eventing:

Install the required custom resource definitions (CRDs) by running the command:
```
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.9.5/eventing-crds.yaml
```

Install the core components of Eventing by running the command:
```
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.9.5/eventing-core.yaml
```
### Verify the installation

Monitor the Knative components until all of the components show a STATUS of Running or Completed. You can do this by running the following command and inspecting the output:
```
kubectl get pods -n knative-eventing
```

### Install a default Channel (messaging) layer

The following commands install the KafkaChannel and run event routing in a system namespace. The knative-eventing namespace is used by default.

Install the Kafka controller by running the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-controller.yaml
```

Install the KafkaChannel data plane by running the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-channel.yaml
```

If you're upgrading from the previous version, run the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-post-install.yaml
```

### Install a Broker layer

The following commands install the Apache Kafka Broker and run event routing in a system namespace. The *knative-eventing* namespace is used by default.

Install the Kafka controller by running the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-controller.yaml
```

Install the Kafka Broker data plane by running the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-broker.yaml
```

If you're upgrading from the previous version, run the following command:
```
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.9.0/eventing-kafka-post-install.yaml
```

For more information, see the Kafka Broker documentation.

## Install Knative Functions

You can install func by downloading the executable binary for your system and placing it in the system path.

Download the binary for your system from the func release page.

Rename the binary to func and make it executable by running the following commands:

```
mv <path-to-binary-file> func

chmod +x func
```

Where <path-to-binary-file> is the path to the binary file you downloaded in the previous step, for example, func_darwin_amd64 or func_linux_amd64.

Move the executable binary file to a directory on your PATH by running the command:
```
mv func /usr/local/bin
```

Verify that the CLI is working by running the command:

```
func version
```
## Create a function

After you have installed Knative Functions, you can create a function project by using the func CLI or the kn func plugin:

```
func create -l <language> <function-name>
```
Example:

```
func create -l node hello-function
```
## Deploy a function

The deploy command uses the function project name as the Knative Service name. When the function is built, the project name and the image registry name are used to construct a fully qualified image name for the function.

Deploy the function by running the command inside the project directory:
```
func deploy --registry <registry>
```
Example:

```
func deploy --registry registry.salaolimpo.cloud 
```

## Invoke a function
You can now invoke the action from shell.
```
func invoke
```


