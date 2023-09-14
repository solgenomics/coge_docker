#!/bin/bash

# create log files for yerba
mkdir -p /opt/Yerba/log;
touch /opt/Yerba/log/access.log
touch /opt/Yerba/log/yerbad.log
touch /opt/Yerba/log/workqueue.log
chmod 777 -R /opt/Yerba/log;