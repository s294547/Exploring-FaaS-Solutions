apiHost=$(kubectl describe nodes | grep "InternalIP" | awk '{print $2}')
domain_name=$(nslookup $apiHost | awk -F'= ' '/name =/ {print $2}')

helm install traefik chartmuseum/traefik -n traefik --set global.domain_name=$domain_name --set global.ipv4_address=$apiHost