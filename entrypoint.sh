#!/bin/bash

# start mariadb and load schema
#
/etc/init.d/mariadb start
mariadb -e "CREATE DATABASE coge" 
cat /home/production/coge/web/coge_mysql_schema.sql |  mariadb coge
mariadb -e "CREATE USER 'coge_web'@'localhost' IDENTIFIED BY 'coge'" 
mariadb -e "GRANT ALL PRIVILEGES ON *.* TO 'coge_web'@'localhost' WITH GRANT OPTION" 

service apache2 restart

# don't disconnect for now
tail -f /etc/hosts

