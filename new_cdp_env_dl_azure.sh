#!/bin/sh

export SUBSCRIPTIONID="3b4df54c-3c29-4484-a5bf-a4aee6d2eb0f"
export AZUREREGION="westcentralus"
export RESOURCEGROUPNAME="chrisv-dl2"
export ENVIRONMENTNAME="cpvdl2"

#Create Subsctiption and RG
az account set --subscription $SUBSCRIPTIONID
az group create -l $AZUREREGION -n $RESOURCEGROUPNAME

#Create DataLake
az storage account create -n $ENVIRONMENTNAME -g $RESOURCEGROUPNAME -l $AZUREREGION --sku Standard_LRS
#Create Data Lake Containers
az storage fs create -n "data" --account-name $ENVIRONMENTNAME --auth-mode login
az storage fs create -n "logs" --account-name $ENVIRONMENTNAME --auth-mode login

#Create Networking
az network vnet create --name "$ENVIRONMENTNAME-Vnet" --resource-group $RESOURCEGROUPNAME
az network nsg create --name "$ENVIRONMENTNAME-NSG" --resource-group $RESOURCEGROUPNAME

#Create Network Security Group
az network nsg rule create -g $RESOURCEGROUPNAME --nsg-name "$ENVIRONMENTNAME-NSG" -n "ssh" --priority 100 \
   --source-port-ranges 22 --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow --protocol Tcp --description "Allow SSH over Port 22"
az network nsg rule create -g $RESOURCEGROUPNAME --nsg-name "$ENVIRONMENTNAME-NSG" -n "ssl" --priority 200 \
   --source-port-ranges 443 --destination-address-prefixes '*' --destination-port-ranges 443 --access Allow --protocol Tcp --description "Allow Port 443"
az network nsg rule create -g $RESOURCEGROUPNAME --nsg-name "$ENVIRONMENTNAME-NSG" -n "cdp-mgmtplane" --priority 300 \
   --source-port-ranges 8443 --destination-address-prefixes '*' --destination-port-ranges 8443 --access Allow --protocol Tcp --description "Allow CDP Management Plane to access over Port 8443"

#Create Subnets
az network vnet subnet create -g $RESOURCEGROUPNAME --vnet-name "$ENVIRONMENTNAME-Vnet" -n "CDP" --address-prefixes 10.0.0.0/24 --network-security-group "$ENVIRONMENTNAME-NSG"\
  --service-endpoints Microsoft.Storage Microsoft.Sql
az network vnet subnet create -g $RESOURCEGROUPNAME --vnet-name "$ENVIRONMENTNAME-Vnet" -n "CDW" --address-prefixes 10.0.1.0/24 --network-security-group "$ENVIRONMENTNAME-NSG"
az network vnet subnet create -g $RESOURCEGROUPNAME --vnet-name "$ENVIRONMENTNAME-Vnet" -n "CML" --address-prefixes 10.0.2.0/24 --network-security-group "$ENVIRONMENTNAME-NSG"

#Create Managed Identities
az identity create -g $RESOURCEGROUPNAME -n "$ENVIRONMENTNAME-AssumerIdentity"
az identity create -g $RESOURCEGROUPNAME -n "$ENVIRONMENTNAME-DataAccessIdentity"
az identity create -g $RESOURCEGROUPNAME -n "$ENVIRONMENTNAME-LoggerIdentity"
az identity create -g $RESOURCEGROUPNAME -n "$ENVIRONMENTNAME-RangerIdentity"

#Get Managed Identities Object IDs
export STORAGEACCOUNTNAME=$(az storage account list -g $RESOURCEGROUPNAME|jq '.[]|.name'| tr -d '"')
export ASSUMER_OBJECTID=$(az identity list -g $RESOURCEGROUPNAME|jq '.[]|{"name":.name,"principalId":.principalId}|select(.name | test("AssumerIdentity"))|.principalId'| tr -d '"')
export DATAACCESS_OBJECTID=$(az identity list -g $RESOURCEGROUPNAME|jq '.[]|{"name":.name,"principalId":.principalId}|select(.name | test("DataAccessIdentity"))|.principalId'| tr -d '"')
export LOGGER_OBJECTID=$(az identity list -g $RESOURCEGROUPNAME|jq '.[]|{"name":.name,"principalId":.principalId}|select(.name | test("LoggerIdentity"))|.principalId'| tr -d '"')
export RANGER_OBJECTID=$(az identity list -g $RESOURCEGROUPNAME|jq '.[]|{"name":.name,"principalId":.principalId}|select(.name | test("RangerIdentity"))|.principalId'| tr -d '"')


# Assign Managed Identity Operator role to the assumerIdentity principal at subscription scope
az role assignment create --assignee $ASSUMER_OBJECTID --role 'f1a07417-d97a-45cb-824c-7a7467783830' --scope "/subscriptions/$SUBSCRIPTIONID"
# Assign Virtual Machine Contributor role to the assumerIdentity principal at subscription scope
az role assignment create --assignee $ASSUMER_OBJECTID --role '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' --scope "/subscriptions/$SUBSCRIPTIONID"
# Assign Storage Blob Data Contributor role to the loggerIdentity principal at logs filesystem scope
az role assignment create --assignee $LOGGER_OBJECTID --role 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' \
   --scope "/subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/logs"
# Assign Storage Blob Data Owner role to the dataAccessIdentity principal at logs/data filesystem scope
az role assignment create --assignee $DATAACCESS_OBJECTID --role 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' \
   --scope "/subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/data"
az role assignment create --assignee $DATAACCESS_OBJECTID --role 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' \
   --scope "/subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/logs"
# Assign Storage Blob Data Contributor role to the rangerIdentity principal at data filesystem scope
az role assignment create --assignee $RANGER_OBJECTID --role 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' \
   --scope "/subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/data"



