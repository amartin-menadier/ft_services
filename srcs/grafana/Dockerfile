FROM	alpine

RUN		echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
		>> /etc/apk/repositories \
		&& apk update \
		&& apk add --no-cache grafana

COPY	dashboards/ /usr/share/grafana/dashboards

WORKDIR	/usr/share/grafana/conf

COPY	dashboards.yaml ./provisioning/dashboards/dashboards.yaml
COPY	influxdb.yaml ./provisioning/datasources/influxdb.yaml

ENV		GF_SECURITY_ADMIN_USER=admin
ENV		GF_SECURITY_ADMIN_PASSWORD=admin

EXPOSE	3000

CMD		["grafana-server"]