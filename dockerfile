FROM mysql:8.0
EXPOSE 3306
COPY tfi_heros.sql /docker-entrypoint-initdb.d
ENV MYSQL_ROOT_PASSWORD=admin123
