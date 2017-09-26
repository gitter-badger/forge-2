#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

# Avoid ERROR: {max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]}
sudo sysctl -w vm.max_map_count=262144

sudo systemctl start elasticsearch.service

sleep 3
wait_for_port_to_be_open "127.0.0.1" "9300" 240  || error_exit "Cannot open port 9300"
sleep 3

# Configure shards and replicas
TEMPLATE='http://localhost:9200/_template/template_all'
CURL='/usr/bin/curl'
OP='-XPUT'
PAYLOAD="{\"template\" : \"*\", \"order\" : 0, \"settings\" : {\"number_of_shards\" : ${number_of_shards}, \"number_of_replicas\" : ${number_of_replicas} }}"
log info "Command: $CURL $OP $TEMPLATE -d '${PAYLOAD}'"
$CURL $OP $TEMPLATE -d "${PAYLOAD}" || error_exit "Failed executing Elasticsearch configuration with number_of_shards ${number_of_shards} and number_of_replicas ${number_of_replicas}" $?

log end
