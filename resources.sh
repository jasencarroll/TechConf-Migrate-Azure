#! /bin/sh

# before we start load variables
chmod +x variables.sh
source variables.sh

# az login

# start with creating a resource group
az group create --name $resourceGroup --location $region

# create the PostgreSQL
az postgres server create \
  -n $elephantServer \
  -g $resourceGroup \
  --location $region \
  --admin-user $userAdmin \
  --admin-password $AdminPass

az postgres server show \
  --resource-group $resourceGroup \
  --name $elephantServer

# Update firewalls
az postgres server firewall-rule create \
  --resource-group $resourceGroup \
  --server $sqlDB \
  --name AzureAcess \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255 

az postgres server firewall-rule create \
  --resource-group $resourceGroup
  --server $sqlDB \
  --name clientIP \
  --startip-address $clientIP \
  --end-address $clientIP

# then create a storage account
az storage account create \
  --name $storageAccount \
  --location $region \
  --resource-group $resourceGroup \
  --sku Standard_LRS \
  --allow-blob-public-access

az servicebus namespace create \
  --name $serviceBus \
  --resource-group $resourceGroup \
  --location $region \
  --sku basic

az servicebus queue create \
  --resource-group $resourceGroup \
  --namespace-name $serviceBus  \
  --name $queue \
  --enable-partitioning true

# afterwards create a function app
az functionapp create \
  --name $functionApp  \
  --storage-account $storageAccount \
  --consumption-plan-location $region \
  --resource-group $resourceGroup \
  --functions-version 3 \
  --os-type Linux \
  --runtime python

# Finally add the storage account, like it says in the order of the README.md \
# because the server will be available by now to create the SQL database
az postgres db create \
  --name $sqlDB \
  --resource-group $resourceGroup \
  --server $elephantServer   

#Restore the database  
pg_restore -h $elephantServer.postgres.database.azure.com \
  -p 5432 \
  --no-tablespaces \
  -W -O -F t -x \
  -d $sqlDB \
  -U $userAdmin@$elephantServer\
  /c/Users/jasen/dev/migration/data/techconfdb_backup.tar