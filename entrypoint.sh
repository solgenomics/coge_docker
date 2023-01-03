#!/bin/bash

# start mariadb and load schema
#
/etc/init.d/mariadb start
mariadb -e "CREATE DATABASE coge" 
cat /home/production/coge/web/coge_mysql_schema.sql |  mariadb coge



# don't disconnect for now
tail -f /etc/hosts

