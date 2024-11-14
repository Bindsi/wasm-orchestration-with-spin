#! /bin/bash

export CLUSTER_NAME=wasm-aio
export STORAGE_ACCOUNT_NAME=sawasmaio
export SCHEMA_REGISTRY_NAME=sr-wasm-aio
export RESOURCE_GROUP=rg-wasm-aio
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export LOCATION=westeurope

# register providers
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.IoTOperations"
az provider register -n "Microsoft.DeviceRegistry"

# install CLI extensions
echo "Installing CLI extensions..."
az extension add --upgrade --name connectedk8s --yes
az extension add --upgrade --name azure-iot-ops --yes

# create resource group
if [ ! $(az group exists -n $RESOURCE_GROUP) ]; then
    echo "Creating RG $RESOURCE_GROUP..."
    az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
fi

# connect arc cluster
echo "Connecting cluster $CLUSTER_NAME..."
az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

# get object id of app registration
echo "Getting object id of app registration..."
export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

# enable custom location support on cluster
echo "Enabling custom location support on cluster $CLUSTER_NAME..."
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

# create storage account
echo "Creating storage account"
saId=$(az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP --enable-hierarchical-namespace -o tsv --query id)

# create schema registry
echo "Creating schema registry..."
srId=$(az iot ops schema registry create -n $SCHEMA_REGISTRY_NAME -g $RESOURCE_GROUP --registry-namespace $SCHEMA_REGISTRY_NAME --sa-resource-id $saId -o tsv --query id)

# deploy AIO
echo "Deploying AIO..."
az iot ops init --debug --cluster $CLUSTER_NAME -g $RESOURCE_GROUP
az iot ops create -n $CLUSTER_NAME --cluster $CLUSTER_NAME -g $RESOURCE_GROUP --sr-resource-id $srId --kubernetes-distro K3s --add-insecure-listener
