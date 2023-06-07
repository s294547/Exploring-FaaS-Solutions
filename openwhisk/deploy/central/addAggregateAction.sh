#getting the script parameters
actionName=$1
ruleName=$2
actionFile=$3

domainName=$(yq e '.domain_name' ./../parameters/parameters.yml)
releaseName=$(yq e '.releaseName' ./../parameters/parameters.yml)
influxCentralUrl=$(yq e '.influxdb.central.externalUrl' ./../parameters/parameters.yml)
influxCentralUrl+=".$domainName"
influxCentralBucket=$(yq e '.influxdb.central.bucket' ./../parameters/parameters.yml)
influxCentralOrg=$(yq e '.influxdb.central.org' ./../parameters/parameters.yml)
influxCentralToken=$(yq e '.influxdb.central.token' ./../parameters/parameters.yml)
influxEdgeUrl="http://$releaseName-influxdb2:80"
influxEdgeBucket=$(yq e '.influxdb.edge.bucket' ./../parameters/parameters.yml)
influxEdgeOrg=$(yq e '.influxdb.edge.org' ./../parameters/parameters.yml)
influxEdgeToken=$(yq e '.influxdb.edge.token' ./../parameters/parameters.yml)

# Configure actions and triggers
wsk action create $actionName ./openwhisk/actions-and-triggers/aggregates/$actionFile --param local_url "$influxEdgeUrl" --param local_token "$influxEdgeToken" --param local_org "$influxEdgeOrg" --param local_bucket "$influxEdgeBucket" --param central_url "https://$influxCentralUrl" --param central_token "$influxCentralToken" --param central_org "$influxCentralOrg" --param central_bucket "$influxCentralBucket" -i
wsk rule create $ruleName aggregatesTrigger $actionName -i

