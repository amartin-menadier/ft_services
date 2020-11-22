FROM	alpine

RUN		apk update \
			&& apk add --no-cache influxdb 

EXPOSE	8086

CMD		["influxd", "run"]