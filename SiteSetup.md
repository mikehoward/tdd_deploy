# Site Setup.

Assumes running on Linode - but should translate
Assumes Arch linux - but should translate

The rest of this refers to these three variables. But, the
code fragments won't necessarily work.

    export SITE=
    export DATABASE=$SITE
    export USERNAME=$SITE
    export PASSWORD=<something>

## Create Postgresql User

    echo 'create user $USERNAME createdb;' | psql postgres postgres

    echo "create database $DATABASE with owner $USERNAME encoding 'utf-8' template template0 ;" | \
        psql postgres postgres

## Create Account

as root

    useradd --comment 'admin for $SITE' --user-group --create-home --password $PASSWORD $USERNAME
    echo "$USERNAME ALL=(ALL) ALL" >>/etc/sudoers

## as USERNAME

    chmod 744 .
    mkdir sites
    mkdir $SITE
    sudo chgrp http $SITE sites
    sudo chmod 750 $SITE sites
    sudo chmod g+s $SITE sites

### install rvm

    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

### install ruby 1.9.2

    rvm install 1.9.2
    (wait)
    rvm use 1.9.2 --default

    gem install bundler
    
### install and configure thin

TBD - once I figure it out

    SITE_PATH=<absolute path to site>
    PORT_BASE=<lowest port number the thin daemons will use>
    SERVERS=<number of server daemons to spin up>

thin config file:

    --- 
    chdir: $SITE_PATH
    environment: production
    address: 127.0.0.1
    port: $PORT_BASE
    timeout: 30
    log: log/thin.log
    pid: $SITE_PATH/tmp/pids/thin.pid
    max_conns: 1024
    max_persistent_conns: 512
    require: []

    wait: 30
    servers: $SERVERS
    daemonize: true

