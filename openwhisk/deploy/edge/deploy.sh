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
mosquittoEncPassword=$(yq e '.mosquitto.password' ./../parameters/parameters.yml)
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
# updating openwhisk values 


yq e '.openwhisk.auth.guest= "'$owGuestAuth'"' ./values.yaml -i 
yq e '.openwhisk.db.host= "'$couchdbGateway'"' ./values.yaml -i
yq e '.openwhisk.db.auth.username= "'$couchdbUsername'"' ./values.yaml -i
yq e '.openwhisk.db.auth.password= "'$couchdbPassword'"' ./values.yaml -i
yq e '.openwhisk.db.port= '$couchdbExtPort'' ./values.yaml -i

# updating influxdb values 

yq e '.influxdb2.adminUser.user= "'$influxEdgeUsername'"' ./values.yaml -i
yq e '.influxdb2.adminUser.password= "'$influxEdgePassword'"' ./values.yaml -i
yq e '.influxdb2.adminUser.token= "'$influxEdgeToken'"' ./values.yaml -i
yq e '.influxdb2.adminUser.organization= "'$influxEdgeOrg'"' ./values.yaml -i
yq e '.influxdb2.adminUser.bucket= "'$influxEdgeBucket'"' ./values.yaml -i


# updating mosquitto values 

yq e '.mosquitto.auth.users[0].username= "'$mosquittoUsername'"' ./values.yaml -i
yq e '.mosquitto.auth.users[0].password= "'$mosquittoEncPassword'"' ./values.yaml -i
yq e '.mosquitto.service.mqttPort= "'$mosquittoPort'"' ./values.yaml -i

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

helm upgrade --install $releaseName chartmuseum/edge-chart -n $1 -f ./values.yaml


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
echo "Job $JOB_NAME has completed. Installation completed"

# Set the name of the service
service_name="$releaseName-mosquitto"

# Get the NodePort of the service
mqtt_port=$(kubectl get svc ${service_name} -n $1 -o=jsonpath='{.spec.ports[0].nodePort}')

#setting the config file of the sensors code
sed -i "s/#define ssid.*/#define ssid \"$ssid\;"/" ./sensors/send_telemetry/config.h
sed -i "s/#define password.*/#define password \"$password\";/" ./sensors/send_telemetry/config.h
sed -i "s/#define mqtt_broker.*/#define mqtt_broker \"$apiHost\";/" ./sensors/send_telemetry/config.h
sed -i "s/#define topic.*/#define topic \"test\";/" ./sensors/send_telemetry/config.h
sed -i "s/#define mqtt_username.*/#define mqtt_username \"$mosquittoUsername\";/" ./sensors/send_telemetry/config.h
sed -i "s/#define mqtt_password.*/#define mqtt_password \"$mosquittoPassword\";/" ./sensors/send_telemetry/config.h
sed -i "s/#define mqtt_port.*/#define mqtt_port $mqtt_port;/" ./sensors/send_telemetry/config.h