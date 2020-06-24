FROM alpine

RUN apk add \
	nginx \
	openssl \
	;

RUN mkdir -p \
	/run/nginx	\
	/etc/nginx/ssl	\
	;

RUN openssl req -x509 -nodes \
	-days 365 \
	-subj "/C=CA/ST=QC/O=UBiqube/CN=ubiqube.com" \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/server.key \
	-out    /etc/nginx/ssl/server.crt \
	;

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN apk add nginx-mod-stream
COPY syslogs.conf /etc/nginx/modules/

CMD ["nginx", "-g", "daemon off;"]
