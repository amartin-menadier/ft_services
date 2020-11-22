FROM	alpine

RUN		apk update \
		&& apk add --no-cache mariadb mariadb-client openrc

COPY	. .

RUN		cat mariadb-server.cnf > /etc/my.cnf.d/mariadb-server.cnf

RUN		mkdir -p /run/mysqld

RUN		chmod 777 ./start.sh 

EXPOSE	3306

CMD		["/bin/ash", "start.sh"]
