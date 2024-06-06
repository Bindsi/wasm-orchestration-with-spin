#! /bin/bash

# deploy non-tls broker listener
echo "Deploying non-tls broker listener..."
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/explore-iot-operations/main/samples/quickstarts/az-mqtt-non-tls-listener.yaml -n azure-iot-operations

sleep 10
# replace the mqtt address in the orderprocessor and fulfilmentprocessor spin.toml files
echo "Replacing mqtt address..."
ip=$(kubectl get svc aio-mq-dmqtt-frontend-nontls -n azure-iot-operations -o json | jq -r ".spec.clusterIP")
mqttAddress="mqtt://$ip:1883"
mosquittoAddress="mqtt://10.43.236.145:1883"
sed -i "s?$mosquittoAddress?$mqttAddress?g" ./apps/mqtt/orderprocessor/spin.toml
sed -i "s?$mosquittoAddress?$mqttAddress?g" ./apps/mqtt/fulfilmentprocessor/spin.toml

# increment the version in the orderprocessor spin.toml file
echo "Incrementing version of orderprocessor..."
version=`grep ^version ./apps/mqtt/orderprocessor/spin.toml | cut -d'"' -f 2`

IFS='.' read -ra ADDR <<< "$version"
major=${ADDR[0]}
minor=${ADDR[1]}
patch=${ADDR[2]}

patch=$((patch + 1))
old_version="version = \"$version\""
new_version="version = \"$major.$minor.$patch\""
sed -i "s?$old_version?$new_version?g" ./apps/mqtt/orderprocessor/spin.toml

# increment the version in the fulfilmentprocessor spin.toml file
echo "Incrementing version of fulfilmentprocessor..."
version=`grep ^version ./apps/mqtt/fulfilmentprocessor/spin.toml | cut -d'"' -f 2`

IFS='.' read -ra ADDR <<< "$version"
major=${ADDR[0]}
minor=${ADDR[1]}
patch=${ADDR[2]}

patch=$((patch + 1))
old_version="version = \"$version\""
new_version="version = \"$major.$minor.$patch\""
sed -i "s?$old_version?$new_version?g" ./apps/mqtt/fulfilmentprocessor/spin.toml
