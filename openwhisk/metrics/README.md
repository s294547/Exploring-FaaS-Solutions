# METRICS

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Enable Metrics](#enable-metrics)

## Introduction

This folder contains all the work related to the analysis of metrics related to my thesis project

You will find two sub-folders:
1. [prometheus]: This folder contains the helm chart to deploy prometheus on a cluser.
2. [prometheus-operator]: This folder contains the helm chart to deploy prometheus operator on a cluster.
3. [k3s-exporter-stack]: This folder contains the helm chart to deploy the exporter of metric for a k3s cluster.
4. [openwhisk]: This folder contains the details related on how getting metrics from OpenWhisk.

The entire results of this research, which has been done to show the feasibility of the architecture, can be found in the thesis section "Demonstration of Feasibility".

## Enable Metrics

To enable the gathering of metrics, the following steps should be done:

1. Deploy prometheus operator in the cluser.
2. Deploy prometheus in the cluster.
3. Deploy the exporter of the cluster metrics, the *k3s-exporter-stack*.
4. Enable openwhisk to share metrics, enable Prometheus to get them, visualize them on Grafana.



