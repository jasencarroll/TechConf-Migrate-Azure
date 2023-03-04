#! /bin/sh

# before we start load variables
########################################
# General purpose variables
# randomID=$RANDOM
########################################
randomID=jc998657
resourceGroup=$"rg$randomID"
###########################################
# Must be unique worldwide
region='westus3'
########################################
# Variables for PostgreSQL resources
# Needs to be lower ca6e
elephantServer="post$randomID" 
sqlDB="techconfdb"
storageAccount="blob$randomID"
serviceBus="sb$randomID"
queue="queue$randomID"
functionApp="funcApp$randomID"
webApp="TCWApp$randomID"
echo "loaded"