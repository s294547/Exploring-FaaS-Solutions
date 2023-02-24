# EFK

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Elastic Search helm repo](#elastic-search-helm-repo)
3. [Deploy Elasticsearch](#deploy-elasticsearch)
4. [Deploy Kibana](#deploy-kibana)
5. [Deploy Fluentd](#deploy-fluentd)


## Introduction
This repository, up to now, contains the files and instructions to setup the EFK stack. We have a directory for Elastic, Fluentd and Kibana.

This example was done using Docker Desktop on Windows 11 with Ubuntu 22 WSL 2. 

EFK stands for Elasticsearch, Fluentd, and Kibana. EFK is a popular and the best open-source choice for the Kubernetes log aggregation and analysis.

Elasticsearch is a distributed and scalable search engine commonly used to sift through large volumes of log data. It is a NoSQL database based on the Lucene search engine (search library from Apache). Its primary work is to store logs and retrive logs from fluentd.

Fluentd is a log shipper. It is an open source log collection agent which support multiple data sources and output formats. Also, it can forward logs to solutions like Stackdriver, Cloudwatch, elasticsearch, Splunk, Bigquery and much more. To be short, it is an unifying layer between systems that genrate log data and systems that store log data.

Kibana is UI tool for querying, data visualization and dashboards. It is a query engine which allows you to explore your log data through a web interface, build visualizations for events log, query-specific to filter information for detecting issues. You can virtually build any type of dashboards using Kibana. Kibana Query Language (KQL) is used for querying elasticsearch data. Here we use Kibana to query indexed data in elasticsearch.

Also, Elasticsearch helps solve the problem of separating huge amounts of unstructured data and is in use by many organizations. Elasticsearch is commonly deployed alongside Kibana.

## Elastic Search helm repo

Execute the following commands to add the Elastic Search helm repo:

```
helm repo add elastic https://helm.elastic.co
helm repo update
```
## Deploy Elasticsearch

At first, create a values-2.yaml inside the directory *elasticsearch*. [This](./elasticsearch/values-2.yaml) is an example of possible file that can be used. The code is the following:

```
replicas: 1
minimumMasterNodes: 1

ingress:
  enabled: false

discovery:
  type: "single-node"
 
  
volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 10Gi
```
Then, execute the command:

```
helm install eck-elasticsearch elastic/elasticsearch -f values-2.yaml  -n logging --create-namespace
```

Wait for the pod *elasticsearch-master-0* to be fully running befor deploying kibana.

## Deploy Kibana

At first, create a values2.yaml inside the directory *kibana*. [This](./kibana/values2.yaml) is an example of possible file that can be used. The code is the following:

```
elasticsearchHosts: "https://elasticsearch-master:9200"
ingress:
  enabled: false
```
Then, execute the command:

```
helm install eck-kibana elastic/kibana -f values2.yaml  -n logging 
```
Create also the [IngressRoute](./kibana/ingress-kibana.yaml) to have access to elastic with the GUI. An example of yaml can be:

```
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: kibana
  labels:
    app: kibana
spec:
  routes:
  - kind: Rule
    match: Host(`kibana-gateway.liquidfaas.cloud`)
    services:
    - kind: Service
      name: eck-kibana-kibana
      namespace: logging
      port: 5601
```


## Deploy Fluentd

We must create different resources. At first, create a [*fluentd-sa.yaml*](./fluentd/fluentd-sa.yaml) inside the directory *fluentd*. The code is the following:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: logging
  labels:
    app: fluentd
```
Create a [*fluentd-role.yaml*](./fluentd/fluentd-role.yaml) inside the directory *fluentd*. The code is the following:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentd
  labels:
    app: fluentd
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - namespaces
  verbs:
  - get
  - list
  - watch
```

Create a [*fluentd-rb.yaml*](./fluentd/fluentd-rb.yaml) inside the directory *fluentd*. The code is the following:

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluentd
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: logging
```
Finally, create a [*fluentd-ds.yaml*](./fluentd/fluentd-ds.yaml) inside the directory *fluentd*. The code is the following:

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1.15.3-debian-elasticsearch7-1.1
        env:
          - name:  FLUENT_ELASTICSEARCH_HOST
            value: "elasticsearch-master.logging.svc.cluster.local"
          - name:  FLUENT_ELASTICSEARCH_PORT
            value: "9200"
          - name: FLUENT_ELASTICSEARCH_SCHEME
            value: "https"
          - name: FLUENTD_SYSTEMD_CONF
            value: disable
          - name: FLUENT_ELASTICSEARCH_USER
            valueFrom:
              secretKeyRef:
                key: username
                name: elasticsearch-master-credentials # The password you've got. These are the defaults. # The username you've set up for elasticsearch
          - name: FLUENT_ELASTICSEARCH_PASSWORD
            valueFrom:
              secretKeyRef:
                key: password
                name: elasticsearch-master-credentials # The password you've got. These are the defaults.
          - name: FLUENT_ELASTICSEARCH_SSL_VERIFY
            value: "false"
          - name: FLUENT_ELASTICSEARCH_SSL_VERSION
            value: "TLSv1_2"
          - name: FLUENT_ELASTICSEARCH_TLS_VERSION
            value: "TLSv1_2"
          - name: FLUENT_ELASTICSEARCH_TLS_VERIFY
            value: "false"
          - name: SUPPRESS_TYPE_NAME
            value: "true"
        resources:
          limits:
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

Then, execute the commands:

```
kubectl create -f fluentd-role.yaml -n logging
kubectl create -f fluentd-sa.yaml -n logging
kubectl create -f fluentd-rb.yaml -n logging
kubectl create -f fluentd-ds.yaml -n logging
```
Now everything should have been set up properly. 