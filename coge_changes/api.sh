#!/bin/bash
#------------------------------------------------------------------------------
# Script to start/stop Mojolicious development web server (morbo) for this sandbox.
#------------------------------------------------------------------------------

start() {
    # export COGE_HOME=$(pwd)
    # export PERL5LIB=$COGE_HOME/modules/perl/lib/perl5
    export COGE_HOME=/opt/apache2/coge
    export API_LOG=/opt/Yerba/log
    export PERL5LIB=/usr/local/lib/perl/5.18.2    
    export IRODSENV=/home/coge/.irods/.irodsEnv
#    hypnotoad -f ./web/services/api.pl >> ./api.log 2>&1 &
#    ./web/services/api.pl daemon -l http://localhost:3304 >> ./api.log 2>&1 &
    # port=$(grep MOJOLICIOUS_PORT ./coge.conf | cut -d ' ' -f 2)
    port=$(grep MOJOLICIOUS_PORT $COGE_HOME/coge.conf | cut -d ' ' -f 2)
    if [ "$port" == "" ]; then
        port=3303
    fi
    morbo -w $PERL5LIB -l http://localhost:$port $COGE_HOME/web/services/api.pl >> $COGE_HOME/api.log 2>&1 &
    echo "Started API (port $port)"
}

stop() {
#    hypnotoad ./web/services/api.pl --stop
    me=$(whoami)
    pid=$(pgrep -u $me 'morbo')
    if [ "$pid" != "" ]; then 
        kill -9 $pid
        echo "Stopped API (pid $pid)"     
    else
        echo "Not running"
    fi
}

case "$1" in
    start)
        start
        exit 0
        ;;
    stop)
        stop
        exit 0
        ;;
    restart)
        stop
        sleep 1
        start
        exit 0
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}" 1>&2
        exit 1
        ;;
esac
