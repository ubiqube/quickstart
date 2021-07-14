FROM docker.elastic.co/beats/filebeat:7.12.1

RUN usermod -u 1000 filebeat
RUN usermod -g 1000 filebeat
COPY filebeat.yml /usr/share/filebeat/filebeat.yml
#COPY api.yml /usr/share/filebeat/modules.d/
#COPY sms.yml /usr/share/filebeat/modules.d/
USER root
RUN mkdir -p /var/log/filebeat

RUN chown root:filebeat /usr/share/filebeat/filebeat.yml
RUN chown root:filebeat /var/log/filebeat
#RUN chown -R root:filebeat /usr/share/filebeat/modules.d
RUN chmod go-w /usr/share/filebeat/filebeat.yml
#RUN chmod go-w /usr/share/filebeat/modules.d/*.yml
RUN chmod a+rw /var/log/filebeat
USER filebeat
