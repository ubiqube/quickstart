FROM nginx:1.21-alpine
RUN apk add nginx-mod-stream openssl bash && \
    apk upgrade

RUN mkdir -p /etc/nginx/ssl

RUN sed -i -e 's,include /etc/nginx/conf\.d/\*\.conf;,include /etc/nginx/conf.d/http_*.conf;,g' /etc/nginx/nginx.conf
COPY http_nginx.conf /etc/nginx/conf.d/

COPY resources/config/cisco_nx_os/* /usr/share/nginx/html/

