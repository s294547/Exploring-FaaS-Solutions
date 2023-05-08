# GRAFANA

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)

## Introduction

This folder contains the helm charts to deploy grafana and grafana operator in the sub-folder called [helm](./helm/).

I've decided to deploy grafana and grafana operator just in the centralized cluster. In the grafana instance there will be just a grafana dashboard, with multiple panels to show the different types of aggregate data for each data center. It possible to select the specific data center thanks to a template variable. 

I could have also deployed a grafana dashboard for each data center, but I preferred to deploy just a centralized dashboard: in this way, if there is the necessity to add some aggregate data, there is no need to modify all the local instances, but just the centralized one.

While it's true that adding new dashboards to a centralized instance every time a new edge OpenWhisk instance is added can be a bit more work, it's still easier than updating multiple local deployments every time a new aggregate is added. Additionally, having a centralized instance allows you to have a more consistent and cohesive view of your data across all the edge OpenWhisk instances, making it easier to compare and analyze the data.

Furthermore, using a centralized Grafana instance also has the advantage of making it easier to manage user access and permissions to the dashboards. Instead of having to manage access for each local deployment, you can manage access in one place, making it more efficient and secure.


