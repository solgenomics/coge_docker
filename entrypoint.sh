#!/bin/bash

# Irods second part. Install irods bases of preconfigured configs as coge user / maybe in a future we can remove irods server to separate docker and compose 
# create coge user also for postgres
/etc/init.d/postgresql start
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo -u postgres psql -U postgres -c "CREATE USER coge PASSWORD 'coge';"
sudo -u postgres psql -U postgres -c "ALTER USER coge CREATEDB;"
sudo -u postgres createdb coge
sudo -u postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE coge to coge;"
cd /opt/irods-legacy/iRODS
sudo -u coge ./scripts/configure
sudo -u coge make
sudo HOME="/home/coge" -u coge ./scripts/finishSetup --noask

# Yerba part - run setup and create a correct config
/opt/Yerba/bin/yerbad --setup
sudo chown www-data:www-data /opt/Yerba/workflows.db


# start mysql / mariadb and load schema
# TODO: change schema for exteranal db 
sudo service mysql start
mysql -e "CREATE DATABASE coge" 
cat /opt/apache2/coge/web/coge_mysql_schema.sql |  mysql coge
mysql -e "CREATE USER 'coge_web'@'localhost' IDENTIFIED BY 'coge'" 
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'coge_web'@'localhost' WITH GRANT OPTION" 

chmod 777 -R /opt/Yerba/log

service apache2 restart

/usr/bin/supervisord

# don't disconnect for now
tail -f /etc/hosts


