#!/bin/bash
# Set the range of nodeport values to check
start_port=30000
end_port=32767

# Get the nodeport values currently in use in the cluster
nodeports=$(kubectl get svc -A -o jsonpath='{range .items[*]}{range .spec.ports[*]}{.nodePort},""{end}{end}' | tr -d '"')

# Iterate over the nodeport range and check if each port is free
for (( port=$start_port; port<=$end_port; port++ )); do
  if ! echo $nodeports | grep -q "\<$port\>"; then
    node_port=$port
    echo "Found free nodeport: $node_port"
    break
  fi
done

# Check if a free nodeport was found and print an error message if not
if [[ -z $node_port ]]; then
  echo "Unable to find free nodeport in range $start_port-$end_port"
  exit 1
fi

# Get APIHOST
apiHost=$(kubectl describe nodes | grep "InternalIP" | awk '{print $2}')

# Replace the NodePort value in the YAML file
sed -i "s/apiHostPort: [0-9]*/apiHostPort: $node_port/g" ./values.yaml
sed -i "s/httpsNodePort: [0-9]*/httpsNodePort: $node_port/g" ./values.yaml 

# Replace the API host value in the YAML file
sed -i "s/apiHostName: .*/apiHostName: $apiHost/g" ./values.yaml

# utiliy variables
domainName=$(yq e '.domain_name' ./../parameters/parameters.yml)
releaseName=$(yq e '.releaseName' ./../parameters/parameters.yml)
owGuestAuth=$(yq e '.openwhisk.guestAuth' ./../parameters/parameters.yml)
couchdbUsername=$(yq e '.couchdb.username' ./../parameters/parameters.yml)
couchdbPassword=$(yq e '.couchdb.password' ./../parameters/parameters.yml)
couchdbGateway=$(yq e '.couchdb.gateway' ./../parameters/parameters.yml)
couchdbGateway+=".$domainName"
couchdbExtPort=$(yq e '.couchdb.extPort' ./../parameters/parameters.yml)
couchdbSvc=$releaseName
couchdbSvc+="-svc-couchdb"
couchdbSvcPort=$(yq e '.couchdb.svcPort' ./../parameters/parameters.yml)
couchdbUuid=$(yq e '.couchdb.uuid' ./../parameters/parameters.yml)
providerPort=$(yq e '.mosquitto.providerPort' ./../parameters/parameters.yml)
mosquittoPort=$(yq e '.mosquitto.mosquittoPort' ./../parameters/parameters.yml)
mosquittoUsername=$(yq e '.mosquitto.username' ./../parameters/parameters.yml)
mosquittoPassword=$(yq e '.mosquitto.plainPassword' ./../parameters/parameters.yml)
influxCentralUrl=$(yq e '.influxdb.central.externalUrl' ./../parameters/parameters.yml)
influxCentralUrl+=".$domainName"
influxCentralUrlCompl="http://$releaseName-influxdb2:80"
influxCentralBucket=$(yq e '.influxdb.central.bucket' ./../parameters/parameters.yml)
influxCentralOrg=$(yq e '.influxdb.central.org' ./../parameters/parameters.yml)
influxCentralToken=$(yq e '.influxdb.central.token' ./../parameters/parameters.yml)
influxCentralUsername=$(yq e '.influxdb.central.username' ./../parameters/parameters.yml)
influxCentralPassword=$(yq e '.influxdb.central.password' ./../parameters/parameters.yml)
influxEdgeUrl="http://$releaseName-influxdb2:80"
influxEdgeBucket=$(yq e '.influxdb.edge.bucket' ./../parameters/parameters.yml)
influxEdgeOrg=$(yq e '.influxdb.edge.org' ./../parameters/parameters.yml)
influxEdgeToken=$(yq e '.influxdb.edge.token' ./../parameters/parameters.yml)
influxEdgeUsername=$(yq e '.influxdb.edge.username' ./../parameters/parameters.yml)
influxEdgePassword=$(yq e '.influxdb.edge.password' ./../parameters/parameters.yml)
grafanaUsername=$(yq e '.grafana.username' ./../parameters/parameters.yml)
grafanaPassword=$(yq e '.grafana.password' ./../parameters/parameters.yml)
grafanaExtUsername=$(yq e '.grafana.extUsername' ./../parameters/parameters.yml)
grafanaExtPassword=$(yq e '.grafana.extPassword' ./../parameters/parameters.yml)
chartmuseumLink="https://"+$(yq e '.chartmuseum.link' ./../parameters/parameters.yml) 
chartmuseumLink+=".$domainName"

# updating openwhisk values 

yq e '.openwhisk.auth.guest= "'$owGuestAuth'"' ./values.yaml -i 
yq e '.openwhisk.db.host= "'$couchdbSvc'"' ./values.yaml -i
yq e '.openwhisk.db.auth.username= "'$couchdbUsername'"' ./values.yaml -i
yq e '.openwhisk.db.auth.password= "'$couchdbPassword'"' ./values.yaml -i
yq e '.openwhisk.db.port= '$couchdbSvcPort'' ./values.yaml -i

# updating couchdb values 

yq e '.couchdb.adminUsername= "'$couchdbUsername'"' ./values.yaml -i
yq e '.couchdb.adminPassword= "'$couchdbPassword'"' ./values.yaml -i
yq e '.couchdb.service.externalPort= "'$couchdbSvcPort'"' ./values.yaml -i
yq e '.couchdb.iroute.gateway= "'$couchdbGateway'"' ./values.yaml -i
yq e '.couchdb.couchdbConfig.couchdb.uuid= "'$couchdbUuid'"' ./values.yaml -i

# updating grafana values 

yq e '.grafana.auth.admin.username= "'$grafanaUsername'"' ./values.yaml -i
yq e '.grafana.auth.admin.password= "'$grafanaPassword'"' ./values.yaml -i
yq e '.grafana.influx.token= "'$influxCentralToken'"' ./values.yaml -i
yq e '.grafana.influx.organization= "'$influxCentralOrg'"' ./values.yaml -i
yq e '.grafana.influx.bucket= "'$influxCentralBucket'"' ./values.yaml -i 
yq e '.grafana.influx.url= "'$influxCentralUrlCompl'"' ./values.yaml -i
yq e '.grafana.global.domain_name= "'$domainName'"' ./values.yaml -i

# updating influxdb values 


yq e '.influxdb2.adminUser.user= "'$influxCentralUsername'"' ./values.yaml -i
yq e '.influxdb2.adminUser.password= "'$influxCentralPassword'"' ./values.yaml -i
yq e '.influxdb2.adminUser.token= "'$influxCentralToken'"' ./values.yaml -i
yq e '.influxdb2.adminUser.organization= "'$influxCentralOrg'"' ./values.yaml -i
yq e '.influxdb2.adminUser.bucket= "'$influxCentralBucket'"' ./values.yaml -i
yq e '.influxdb2.iroute.externalUrl= "'$influxCentralUrl'"' ./values.yaml -i 

# updating mqtt provider values

yq e '.mqtt-provider.provider.providerPort= "'$providerPort'"' ./values.yaml -i
yq e '.mqtt-provider.provider.couchdbUsername= "'$couchdbUsername'"' ./values.yaml -i
yq e '.mqtt-provider.provider.couchdbPassword= "'$couchdbPassword'"' ./values.yaml -i
yq e '.mqtt-provider.provider.couchdbGateway= "'$couchdbGateway'"' ./values.yaml -i
yq e '.mqtt-provider.provider.couchdbExtPort= "'$couchdbExtPort'"' ./values.yaml -i
yq e '.mqtt-provider.openwhisk.apiHost= "'$apiHost'"' ./values.yaml -i


# the $1 variable contains the namespace
kubectl create namespace $1
helm repo add chartmuseum $chartmuseumLink
helm repo update chartmuseum

helm upgrade --install $releaseName chartmuseum/central-chart -n $1 -f ./values.yaml

# Configure wsk cli
wsk -i property set --apihost $apiHost:$node_port
wsk -i property set --auth $owGuestAuth

JOB_NAME=openwhisk-install-packages

# Wait for the Job to complete
echo "Waiting for $JOB_NAME to complete..."
while true; do
  status=$(kubectl get job $JOB_NAME -n $1 -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
  if [ "$status" == "True" ]; then
    break
  fi
  sleep 1
done

# Run some commands after the Job has completed
echo "Job $JOB_NAME has completed. Running post-job commands..."

# Configure COUCHDB
curl -X PUT "https://$couchdbUsername:$couchdbPassword@$couchdbGateway:$couchdbExtPort/topic_listeners"
curl -X PUT "https://$couchdbUsername:$couchdbPassword@$couchdbGateway:$couchdbExtPort/topic_listeners/_design/subscriptions" --data-binary @./openwhisk/views.json

# restart MQTT provider
kubectl delete pod -n $1 -l name=mqtt-provider

# Add external users to access to grafana
curl -X POST -H 'Content-Type: application/json' -d '{"name":"'$grafanaExtUsername'", "login":"'$grafanaExtUsername'", "password":"'$grafanaExtPassword'" }' https://$grafanaUsername:$grafanaPassword@grafana.$1.$domainName/api/admin/users

#Waiting for MQTT provider to be ready
LABEL_SELECTOR="name=mqtt-provider"


echo "Waiting for pod with label $LABEL_SELECTOR to be ready..."

while [[ $(kubectl get pods -n $1 -l $LABEL_SELECTOR -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    sleep 1
done

echo "Pod with label $LABEL_SELECTOR is ready!"



# Configure actions and triggers
wsk package create --shared yes -p provider_endpoint "http://mqtt-provider:$providerPort/mqtt" mqtt -i
wsk package update mqtt -a description 'The mqtt package provides functionality to connect to MQTT brokers' -i
wsk action create -a feed true mqtt/mqtt_feed ./openwhisk/actions-and-triggers/feed_action.js -i
wsk trigger create /guest/feed_trigger --feed /guest/mqtt/mqtt_feed -p topic 'test' -p url "http://$mosquittoUsername:$mosquittoPassword@$releaseName-mosquitto:$mosquittoPort" -p triggerName '/guest/feed_trigger' -i
wsk trigger get /guest/feed_trigger -i &> /dev/null
if [ $? -eq 0 ]; then
  echo "Trigger already exists"
else
  echo "Trigger does not exist, creating it"
  # try creating the trigger until successful
  while ! wsk trigger create /guest/feed_trigger --feed /guest/mqtt/mqtt_feed -p topic 'test' -p url "http://$mosquittoUsername:$mosquittoPassword@$releaseName-mosquitto:$mosquittoPort" -p triggerName '/guest/feed_trigger' -i &> /dev/null; do
    echo "Trigger creation failed, retrying in 5 seconds"
    sleep 5
  done
fi
wsk action create addReadingToDb ./openwhisk/actions-and-triggers/addReadingsToDB.js --param influx_url "$influxEdgeUrl" --param influx_token "$influxEdgeToken" --param influx_org "$influxEdgeOrg" --param influx_bucket "$influxEdgeBucket" -i
wsk rule create mqttRule '/guest/feed_trigger' addReadingToDb -i

wsk action create aggregatesGasAvgAction ./openwhisk/actions-and-triggers/aggregates/aggregatesGasAvgAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesGasMinAction ./openwhisk/actions-and-triggers/aggregates/aggregatesGasMinAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesGasMaxAction ./openwhisk/actions-and-triggers/aggregates/aggregatesGasMaxAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesHumidityAvgAction ./openwhisk/actions-and-triggers/aggregates/aggregatesHumidityAvgAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesHumidityMinAction ./openwhisk/actions-and-triggers/aggregates/aggregatesHumidityMinAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesHumidityMaxAction ./openwhisk/actions-and-triggers/aggregates/aggregatesHumidityMaxAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesTemperatureAvgAction ./openwhisk/actions-and-triggers/aggregates/aggregatesTemperatureAvgAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesTemperatureMinAction ./openwhisk/actions-and-triggers/aggregates/aggregatesTemperatureMinAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk action create aggregatesTemperatureMaxAction ./openwhisk/actions-and-triggers/aggregates/aggregatesTemperatureMaxAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk trigger create aggregatesTrigger --feed /whisk.system/alarms/alarm -p cron "0 */30 * * * *"  -i
wsk rule create aggregatesGasAvgRule aggregatesTrigger aggregatesGasAvgAction -i
wsk rule create aggregatesGasMinRule aggregatesTrigger aggregatesGasMinAction -i
wsk rule create aggregatesGasMaxRule aggregatesTrigger aggregatesGasMaxAction -i
wsk rule create aggregatesTemperatureAvgRule aggregatesTrigger aggregatesTemperatureAvgAction -i
wsk rule create aggregatesTemperatureMinRule aggregatesTrigger aggregatesTemperatureMinAction -i
wsk rule create aggregatesTemperatureMaxRule aggregatesTrigger aggregatesTemperatureMaxAction -i
wsk rule create aggregatesHumidityAvgRule aggregatesTrigger aggregatesHumidityAvgAction -i
wsk rule create aggregatesHumidityMinRule aggregatesTrigger aggregatesHumidityMinAction -i
wsk rule create aggregatesHumidityMaxRule aggregatesTrigger aggregatesHumidityMaxAction -i