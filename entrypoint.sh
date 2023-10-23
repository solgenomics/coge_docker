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

### Creating folders pa
mkdir -p /work_queue
mkdir -p /work_queue/logs /work_queue/workers
chmod 777 -R /work_queue;
chown -R www-data:www-data /work_queue


mkdir -p /scratch 
mkdir -p /scratch/coge
mkdir -p /scratch/coge/cache /scratch/coge/tmp
mkdir -p /scratch/coge/tmp/downloads /scratch/coge/tmp/results /scratch/coge/tmp/staging /scratch/coge/tmp/uploads
mkdir -p /scratch/coge/tmp/downloads/jobs
mkdir -p /scratch/coge/cache/bed /scratch/coge/cache/blast /scratch/coge/cache/experiments /scratch/coge/cache/fasta /scratch/coge/cache/genomes /scratch/coge/cache/last /scratch/coge/cache/sra 
mkdir -p /scratch/coge/cache/blast/db
chmod 777 -R /scratch;
chown -R www-data:www-data /scratch

mkdir -p /storage
mkdir -p /storage/coge /storage/work_queue
mkdir -p /storage/coge/data
mkdir -p /storage/coge/data/blast /storage/coge/data/genomic_sequence /storage/coge/data/popgen /storage/coge/data/syn3d
mkdir -p /storage/coge/data/blast/matrix
chmod 777 -R /storage;
chown -R coge:coge /storage
###

# start mysql / mariadb and load schemat
# add check if not empty
if ! [ "$(mysql -h coge_db -e "SHOW DATABASES LIKE 'coge'")" ]
then
    mysql -h coge_db -e "CREATE DATABASE coge" 
    cat /opt/apache2/coge/web/coge_mysql_schema.sql |  mysql -h coge_db coge
    mysql -h coge_db -e "CREATE USER 'coge_web'@'%' IDENTIFIED BY 'coge'" 
    mysql -h coge_db -e "GRANT ALL PRIVILEGES ON *.* TO 'coge_web'@'%' WITH GRANT OPTION" 
    echo "database coge was created"
else 
    echo "database coge exists on server"
fi 

chmod 777 -R /opt/Yerba/log

service apache2 restart

/usr/bin/supervisord

# don't disconnect for now
tail -f /etc/hosts


