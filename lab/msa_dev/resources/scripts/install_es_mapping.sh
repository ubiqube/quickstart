#! /bin/sh
#set -x
#
# template installation: https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html
mappings="ubialarms ubiflows ubilogs cache customer-data percolator default_all"
for i in $mappings
do
#  resp=$(curl --write-out %{http_code} --silent --output /dev/null  -XHEAD -i localhost:9200/_template/$i)
resp=$(curl -s -w %{http_code} -o /dev/null  msa_es:9200/_template/$i)
if [ $resp != "200" ]
then
	echo "install mapping "$i" from /etc/elasticsearch/templates/$i.json"
	curl --connect-timeout 1 --max-time 2 -XPUT http://msa_es:9200/_template/$i?include_type_name=true -H "Content-Type: application/json" --data-binary "@/etc/elasticsearch/templates/$i.json"
else
	echo "install mapping failed: "$i" already installed"
fi
done