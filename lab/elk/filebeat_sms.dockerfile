FROM docker.elastic.co/beats/filebeat:7.10.1
COPY filebeat_sms.yaml /usr/share/filebeat/filebeat.yml
USER root
RUN chown root:filebeat /usr/share/filebeat/filebeat.yml
RUN chmod go-w /usr/share/filebeat/filebeat.yml
USER filebeat