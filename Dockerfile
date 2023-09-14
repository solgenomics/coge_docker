
FROM ubuntu:14.04

RUN apt-get update && apt-get install -y apache2 aragorn blast2 build-essential checkinstall expat gcc-multilib git graphviz imagemagick libdb-dev libgd2-xpm-dev libperl-dev libgd-gd2-perl libconfig-yaml-perl \
    libssl-dev libzmq3-dev mysql-server-5.6 ncbi-blast+ ncbi-blast+-legacy njplot phpmyadmin python-dev python-numpy python-software-properties samtools swig sqlite3 ttf-mscorefonts-installer \
    ubuntu-dev-tools libapache-asp-perl libapache2-mod-perl2 libapache2-mod-wsgi python-pip r-cran-plyr r-cran-reshape2 r-cran-ggplot2 libboost-all-dev python-glpk glpk-utils libgmp3-dev \
    zimpl cpanminus

# coge cloning and basic instalation
RUN chmod 777 /opt/
RUN git clone --recursive https://github.com/LyonsLab/coge.git /opt/apache2/coge
WORKDIR /opt/apache2/coge/web
RUN /opt/apache2/coge/web/setup.sh
RUN chmod 777 -R /opt/apache2/coge/web/data
RUN chmod 777 -R /opt/apache2/coge/web/tmp
WORKDIR /opt/apache2/coge/
RUN xargs -a /opt/apache2/coge/modules.txt cpanm --force

# copy makeperl and run
COPY ./make_perl.sh /opt/apache2/coge/make_perl.sh
RUN bash /opt/apache2/coge/make_perl.sh

# node
RUN apt-get purge nodejs -y

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.16.0

RUN sudo curl https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash \
   && . $NVM_DIR/nvm.sh \
   && nvm install $NODE_VERSION \
   && nvm alias default $NODE_VERSION \
   && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# nodejs bower and install packages
RUN npm install -g bower

# copy new coge bower 
COPY ./bower.json /opt/apache2/coge/bower.json
RUN bower install /opt/apache2/coge/bower.json

# download and install cctools version 6.2.11RC1 fromsource 

RUN mkdir /opt/cctools
WORKDIR /opt/cctools
RUN wget http://www3.nd.edu/~ccl/software/files/cctools-6.2.11RC1-source.tar.gz
RUN tar -xf cctools-6.2.11RC1-source.tar.gz
WORKDIR /opt/cctools/cctools-6.2.11RC1-source
RUN ./configure --prefix /usr/local
RUN make
RUN make install

# add user coge for irods server and install irods 
RUN adduser coge && chown -R coge /home/coge
RUN apt-get install postgresql-9.3 -y
RUN apt-get install unixodbc unixodbc-dev odbc-postgresql -y

# link to libraries odbc and postgresql
RUN ln -s /usr/lib/x86_64-linux-gnu/odbc/psqlodbca.so /usr/lib/postgresql/9.3/lib/libodbcpsql.so
COPY ./pg_hba.conf /etc/postgresql/9.3/main
RUN chmod 644 /etc/postgresql/9.3/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.3/main/pg_hba.conf
COPY ./odbc/odbcinst.ini /etc/

# irods server itself - second half of process is in entrypoint.sh 
RUN git clone --recursive https://github.com/irods/irods-legacy.git /opt/irods-legacy
COPY ./irods_conf/*.* /opt/irods-legacy/iRODS/config
RUN chown -R coge:coge /opt/irods-legacy
COPY ./odbc_home/*.* /home/coge
RUN chown -R coge:coge /home/coge
RUN chmod 600 /home/coge/.pgpass

# install python packages for Yerba
RUN apt-get install python-zmq -y
# install non Yerba python packages
RUN apt-get install python-scitools python-matplotlib python-numpy python-naturalsort python-requests python-scipy python-sklearn -y

# Yerba  cloning and instalation
RUN git clone --recursive https://github.com/LyonsLab/Yerba.git /opt/Yerba
COPY ./yerba/yerba.cfg /opt/Yerba
RUN mkdir -p /etc/yerba
COPY ./yerba/yerba.cfg /etc/yerba

# yerba logs move to script later with second script for full folder structure
RUN mkdir -p /opt/Yerba/log;
RUN touch /opt/Yerba/log/access.log
RUN touch /opt/Yerba/log/yerbad.log
RUN touch /opt/Yerba/log/workqueue.log
RUN chmod 777 -R /opt/Yerba/log;
RUN chown -R coge:coge /opt/Yerba
RUN chmod 777 -R /opt/Yerba

# create folder structure on the server
COPY ./folders.sh /folders.sh
RUN bash /folders.sh

# install supervisor process manager / insted of upstart and systemd
RUN mkdir -p /var/log/supervisor
RUN apt-get install supervisor -y
# supervisor services config copy
COPY ./supervisor_configs/*.* /etc/supervisor/conf.d
RUN chmod 644 /etc/supervisor/conf.d;

COPY ./coge-main.conf /etc/apache2/sites-available/coge-main.conf
COPY ./coge.conf /opt/apache2/coge/coge.conf

# RUN service apache2 restart
RUN a2enmod rewrite headers proxy proxy_http expires perl ssl
RUN a2dissite 000-default && a2ensite coge-main.conf

# helpers to remove later
RUN apt-get install lynx nano htop -y

# move it later to the top
COPY ./coge_changes/*.* /opt/apache2/coge/
RUN chmod 777 /opt/apache2/coge/api.sh /opt/apache2/coge/api.log
RUN chown www-data:www-data /opt/apache2/coge/api.log

COPY ./entrypoint.sh /entrypoint.sh

# jbroswe ver 1.12.0 download and configuration
WORKDIR /opt/apache2/coge/web/js/jbrowse
RUN wget https://jbrowse.org/releases/JBrowse-1.12.0.zip
RUN unzip JBrowse-1.12.0.zip
RUN cp -RT /opt/apache2/coge/web/js/jbrowse/JBrowse-1.12.0  /opt/apache2/coge/web/js/jbrowse
RUN cpanm Bio::DB::SeqFeature::Store --force
RUN ./setup.sh
COPY ./jbrowse /opt/apache2/coge/web/js/jbrowse

WORKDIR /opt/apache2/coge/
EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]


