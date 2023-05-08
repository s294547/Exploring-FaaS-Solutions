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
sed -i "s/apiHostPort: [0-9]*/apiHostPort: $node_port/g" ./openwhisk/values.yaml
sed -i "s/httpsNodePort: [0-9]*/httpsNodePort: $node_port/g" ./openwhisk/values.yaml 

# Replace the API host value in the YAML file
sed -i "s/apiHostName: .*/apiHostName: $apiHost/g" ./openwhisk/values.yaml

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

# updating openwhisk values file

yq e '.openwhisk.auth.guest= "'$owGuestAuth'"' ./values.yaml -i 
yq e '.openwhisk.db.host= "'$couchdbSvc'"' ./values.yaml -i
yq e '.openwhisk.db.auth.username= "'$couchdbUsername'"' ./values.yaml -i
yq e '.openwhisk.db.auth.password= "'$couchdbPassword'"' ./values.yaml -i
yq e '.openwhisk.db.port= '$couchdbSvcPort'' ./values.yaml -i

# updating couchdb values file

yq e '.couchdb.adminUsername= "'$couchdbUsername'"' ./values.yaml -i
yq e '.couchdb.adminPassword= "'$couchdbPassword'"' ./values.yaml -i
yq e '.couchdb.service.externalPort= "'$couchdbSvcPort'"' ./values.yaml -i
yq e '.couchdb.iroute.gateway= "'$couchdbGateway'"' ./values.yaml -i
yq e '.couchdb.couchdbConfig.couchdb.uuid= "'$couchdbUuid'"' ./values.yaml -i

# updating grafana values file

yq e '.grafana.auth.admin.username= "'$grafanaUsername'"' ./values.yaml -i
yq e '.grafana.auth.admin.password= "'$grafanaPassword'"' ./values.yaml -i
yq e '.grafana.influx.token= "'$influxCentralToken'"' ./values.yaml -i
yq e '.grafana.influx.organization= "'$influxCentralOrg'"' ./values.yaml -i
yq e '.grafana.influx.bucket= "'$influxCentralBucket'"' ./values.yaml -i 
yq e '.grafana.influx.url= "'$influxCentralUrlCompl'"' ./values.yaml -i
yq e '.grafana.global.domain_name= "'$domainName'"' ./values.yaml -i

# updating influxdb values file


yq e '.influxdb2.adminUser.user= "'$influxCentralUsername'"' ./values.yaml -i
yq e '.influxdb2.adminUser.password= "'$influxCentralPassword'"' ./values.yaml -i
yq e '.influxdb2.adminUser.token= "'$influxCentralToken'"' ./values.yaml -i
yq e '.influxdb2.adminUser.organization= "'$influxCentralOrg'"' ./values.yaml -i
yq e '.influxdb2.adminUser.bucket= "'$influxCentralBucket'"' ./values.yaml -i
yq e '.influxdb2.iroute.externalUrl= "'$influxCentralUrl'"' ./values.yaml -i 



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

# Add external users to access to grafana
curl -X POST -H 'Content-Type: application/json' -d '{"name":"'$grafanaExtUsername'", "login":"'$grafanaExtUsername'", "password":"'$grafanaExtPassword'" }' https://$grafanaUsername:$grafanaPassword@grafana.$1.$domainName/api/admin/users