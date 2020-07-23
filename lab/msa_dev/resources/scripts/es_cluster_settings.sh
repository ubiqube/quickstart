#! /bin/sh
echo " ==== Install default cluster settings configuration ==== "
echo " === Shard Allocation === "
resp=$(curl --connect-timeout 1 --max-time 2 -XPUT 'http://msa_es:9200/_cluster/settings' -H "Content-Type: application/json" -d'{ "transient":{ "cluster.routing.allocation.enable" : "all" }}')
echo "Transient : " $resp
resp=$(curl --connect-timeout 1 --max-time 2 -XPUT 'http://msa_es:9200/_cluster/settings' -H "Content-Type: application/json" -d'{ "persistent":{ "cluster.routing.allocation.enable" : "all" }}')
echo "Persistent : " $resp
echo " === Shard Rebalancing === "
resp=$(curl --connect-timeout 1 --max-time 2 -XPUT 'http://msa_es:9200/_cluster/settings' -H "Content-Type: application/json" -d'{ "transient":{ "cluster.routing.rebalance.enable" : "all" }}')
echo "Transient : " $resp
resp=$(curl --connect-timeout 1 --max-time 2 -XPUT 'http://msa_es:9200/_cluster/settings' -H "Content-Type: application/json" -d'{ "persistent":{ "cluster.routing.rebalance.enable" : "all" }}')
echo "Persistent : " $resp