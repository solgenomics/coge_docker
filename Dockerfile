
FROM debian:bullseye

EXPOSE 8080

RUN adduser -u 1250 production && chown -R production /home/production

apt-get update -y --allow-unauthenticated

apt-get install apache2 aragorn blast2 build-essential checkinstall expat gcc-multilibgit graphviz imagemagick libdb-dev libgd2-xpm-dev libperl-dev libgd-gd2-perl libconfig-yaml-perl libssl-dev libzmq3-dev mysql-server ncbi-blast+ ncbi-blast+-legacy njplot phpmyadmin python-dev python-numpy python-software-properties samtools swig sqlite3 ttf-mscorefonts-installer ubuntu-dev-tools libapache-asp-perl libapache2-mod-perl2 libapache2-mod-wsgi python-pip r-cran-plyr r-cran-reshape2 r-cran-ggplot2 nodejs npm libboost-all-dev python-glpk glpk-utils libgmp3-dev zimpl cpanminus wget

RUN cd /home/production
RUN git clone --recursive https://github.com/LyonsLab/coge.git

RUN cd coge/web &./setup.sh

RUN cat modules.txt | xargs cpanm

RUN bash make_perl.sh

RUN pip install pyzmq matplotlib numpy seaborn natsort requests scipy sklearn

RUN R CMD INSTALL dplyr useful gridExtra

