#! /bin/sh

# before we start load variables
########################################
# General purpose variables
# randomID=$RANDOM
########################################
randomID=jc998757
resourceGroup=$"rg$randomID"
###########################################
# Must be unique worldwide
region='westus3'
########################################
# Variables for PostgreSQL resources
# Needs to be lower ca6e
elephantServer="post$randomID" 
sqlDB="techconfdb"
userAdmin="sql_admin"
AdminPass="P@ssword"
storageAccount="blob$randomID"
serviceBus="sb$randomID"
queue="notificationqueue"
functionApp="funcApp$randomID"
webApp="TCWApp$randomID"
clientIP = $(curl ifconfig.me)
echo "loaded"