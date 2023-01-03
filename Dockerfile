
FROM debian:bullseye

EXPOSE 8080

RUN adduser -u 1250 production && chown -R production /home/production

# need to add non-free to the package manager
#
RUN sed -i -e 's/main/main contrib non-free/g' /etc/apt/sources.list

RUN apt-get update -y --allow-unauthenticated

RUN apt-get -y install apache2 aragorn ncbi-blast+ ncbi-blast+-legacy build-essential checkinstall expat gcc-multilib graphviz imagemagick libdb-dev libperl-dev libgd-dev libgd-gd2-perl libconfig-yaml-perl libssl-dev libzmq3-dev mariadb-server mariadb-client ncbi-blast+ ncbi-blast+-legacy njplot python3-dev python3-numpy python3-software-properties samtools swig sqlite3 ttf-mscorefonts-installer ubuntu-dev-tools libapache-asp-perl libapache2-mod-perl2 libapache2-mod-wsgi-py3 python3-pip r-cran-plyr r-cran-reshape2 r-cran-ggplot2 nodejs npm libboost-all-dev python3-swiglpk glpk-utils libgmp3-dev cpanminus wget findutils sudo

# notes:
# * package zimpl has been removed - replacement?
# * importing python3 instead of python2 - will the software work with 3???
# * some package names were changed,  libapache2-mod-wsgi -> libapache2-mod-wsgi-py3
# myphpadmin did not install
# findutils required for xargs


RUN cd /home/production
RUN git clone --recursive https://github.com/LyonsLab/coge.git /home/production/coge



RUN cd /home/production/coge/web
RUN bash /home/production/coge/web/setup.sh

RUN xargs -a /home/production/coge/modules.txt cpanm --force

WORKDIR /home/production/coge

RUN bash /home/production/coge/make_perl.sh

RUN pip install pyzmq matplotlib numpy seaborn natsort requests scipy sklearn

RUN Rscript -e 'install.packages( c("dplyr", "useful", "gridExtra") )'

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

