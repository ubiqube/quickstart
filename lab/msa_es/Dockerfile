FROM ubiqube/msa2-es:fd10935db6567422d777c60e74d6b3f7dbc27e41


RUN mkdir -p /usr/share/elasticsearch/config

RUN openssl req -x509 -nodes \
    -days 365 \
    -subj "/C=CA/ST=QC/O=UBiqube/CN=msa2.ubiqube.com" \
    -newkey rsa:2048 \
    -keyout /usr/share/elasticsearch/config/server.pem \
    -out    /usr/share/elasticsearch/config/server.crt

RUN chown 1000 /usr/share/elasticsearch/config/server.*

ENTRYPOINT /home/install/scripts/install.sh
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]
