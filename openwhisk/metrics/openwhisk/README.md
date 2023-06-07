# METRICS - OPENWHISK

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Values](#values)
3. [Sending the Metrics to Prometheus](#sending-the-metrics-to-prometheus)


## Introduction

This folder contains all the informations to export OpenWhisk metrics and the related files.
[values.yaml](values.yaml): it contains the values that need to be set to enable exporting metrics in OpenWhisk.
[monitors.yml](monitors.yml): it contians the service monitors and pod monitor to be deployed in the cluster to monitor OpenWhisk metrics.

## Values

To export OpenWhisk metrics, when deploying OpenWhisk, the section must be addedd to the values related to OpenWhisk when deploying the helm chart:

```
metrics:
  # set true to enable prometheus exporter
  prometheusEnabled: truek
  # passing prometheus-enabled by a config file, required by openwhisk
  whiskconfigFile: "whiskconfig.conf"
  # set true to enable Kamon
  kamonEnabled: true
  # set true to enable Kamon tags
  kamonTags: true
  # set true to enable user metrics
  userMetricsEnabled: true
```

## Sending the Metrics to Prometheus

We will be using our own deployed Prometheus. To do so, we must configure it to get metrics exposed by OpenWhisk. The metric are going to be exposed by the OpenWhisk controller on the *http* port. To do that, we must create this service monitor on the namespace related to OpenWhisk:

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: openwhisk-controller
  namespace: openwhisk-second
spec:
  endpoints:
  - path: /metrics
    port: http
  selector:
    matchLabels:
      name: openwhisk-controller
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: openwhisk-user-events
  namespace: openwhisk-second
spec:
  endpoints:
  - path: /metrics
    port: http
  selector:
    matchLabels:
      name: openwhisk-user-events
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: openwhisk-invoker
  namespace: openwhisk-second
spec:
  podMetricsEndpoints:
  - port: invoker
    path: /metrics
  selector:
    matchLabels:
      name: openwhisk-invoker
```