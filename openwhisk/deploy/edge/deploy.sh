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
apiHost="$(kubectl describe nodes | grep "InternalIP" | awk '{print $2}')"

# Replace the NodePort value in the YAML file
sed -i "s/apiHostPort: [0-9]*/apiHostPort: $node_port/g" ./openwhisk/values.yml 
sed -i "s/httpsNodePort: [0-9]*/httpsNodePort: $node_port/g" ./openwhisk/values.yml 

# Replace the API host value in the YAML file
sed -i "s/apiHostName: .*/apiHostName: $apiHost/g" ./openwhisk/values.yml 


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
chartmuseumLink="https://"+$(yq e '.chartmuseum.link' ./../parameters/parameters.yml) 
chartmuseumLink+=".$domainName"
# updating openwhisk values file


yq e '.openwhisk.auth.guest= "'$owGuestAuth'"' ./values.yaml -i 
yq e '.openwhisk.db.host= "'$couchdbGateway'"' ./values.yaml -i
yq e '.openwhisk.db.auth.username= "'$couchdbUsername'"' ./values.yaml -i
yq e '.openwhisk.db.auth.password= "'$couchdbPassword'"' ./values.yaml -i
yq e '.openwhisk.db.port= '$couchdbExtPort'' ./values.yaml -i

# updating influxdb values file

yq e '.influxdb2.adminUser.user= "'$influxEdgeUsername'"' ./values.yaml -i
yq e '.influxdb2.adminUser.password= "'$influxEdgePassword'"' ./values.yaml -i
yq e '.influxdb2.adminUser.token= "'$influxEdgeToken'"' ./values.yaml -i
yq e '.influxdb2.adminUser.organization= "'$influxEdgeOrg'"' ./values.yaml -i
yq e '.influxdb2.adminUser.bucket= "'$influxEdgeBucket'"' ./values.yaml -i


# updating mosquitto values file

yq e '.mosquitto.auth.users[0].username= "'$mosquittoUsername'"' ./values.yaml -i
yq e '.mosquitto.auth.users[0].password= "'$mosquittoEncPassword'"' ./values.yaml -i
yq e '.mosquitto.service.mqttPort= "'$mosquittoPort'"' ./values.yaml -i
yq e '.mosquitto.provider.providerPort= "'$providerPort'"' ./values.yaml -i
yq e '.mosquitto.provider.couchdbUsername= "'$couchdbUsername'"' ./values.yaml -i
yq e '.mosquitto.provider.couchdbPassword= "'$couchdbPassword'"' ./values.yaml -i
yq e '.mosquitto.provider.couchdbGateway= "'$couchdbGateway'"' ./values.yaml -i
yq e '.mosquitto.provider.couchdbExtPort= "'$couchdbExtPort'"' ./values.yaml -i
yq e '.mosquitto.openwhisk.apiHost= "'$apiHost'"' ./values.yaml -i

# the $1 variable contains the namespace
kubectl create namespace $1
helm repo add chartmuseum $chartmuseumLink
helm repo update chartmuseum

helm upgrade --install $releaseName chartmuseum/edge-chart -n $1 -f ./values.yaml

# Configure wsk cli
wsk -i property set --apihost $apiHost:$node_port
# Read the guest value from the YAML file
wsk -i property set --auth $owGuestAuth

JOB_NAME=$releaseName-install-packages

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


# Run the "wsk package list" command and save the output to a variable
output=$(wsk package list -i)

# Check if the output contains the package you're looking for
if [[ $output == *"mqtt"* ]]; then
    echo "Found the mqtt package. Stopping script."
    exit
fi

# If the script hasn't been stopped yet, continue with whatever actions you want to perform below this line
echo "Did not find the mqtt package. Continuing with script."

# Configure actions and triggers
wsk package create --shared yes -p provider_endpoint "http://mqtt-provider:$providerPort/mqtt" mqtt -i
wsk package update mqtt -a description 'The mqtt package provides functionality to connect to MQTT brokers' -i
wsk action create -a feed true mqtt/mqtt_feed ./openwhisk/actions-and-triggers/feed_action.js -i
wsk trigger create /guest/feed_trigger --feed /guest/mqtt/mqtt_feed -p topic 'test' -p url "http://$mosquittoUsername:$mosquittoPassword@$1-mosquitto:$mosquittoPort" -p triggerName '/guest/feed_trigger' -i
wsk action create addReadingToDb ./openwhisk/actions-and-triggers/addReadingsToDB.js --param influx_url "$influxEdgeUrl" --param influx_token "$influxEdgeToken" --param influx_org "$influxEdgeOrg" --param influx_bucket "$influxEdgeBucket" -i
wsk rule create mqttRule '/guest/feed_trigger' addReadingToDb -i

wsk action update aggregatesAction ./openwhisk/actions-and-triggers/aggregatesAction.js --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk trigger create aggregatesTrigger --feed /whisk.system/alarms/alarm -p cron "0 */30 * * * *" -i
wsk rule create aggregatesRule aggregatesTrigger aggregatesAction -i