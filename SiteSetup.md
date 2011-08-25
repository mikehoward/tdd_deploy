# Site Setup.

Assumes running on Linode - but should translate
Assumes Arch linux - but should translate

The rest of this refers to these three variables. But, the
code fragments won't necessarily work.

    export SITE=
    export DATABASE=$SITE
    export SITE_USER=$SITE
    export PASSWORD=<something>
    
## Test Driven Site Setup

The tests/hosts directory contains a bunch of tests which run commands
on hosts - either selected hosts, or all hosts defined in the :hosts role
in the Capfile.

The test parameters may be set by defining environment variables.

For Host Provisioning Testing

* HOSTS - list of hosts to run tests on. Default is all hosts defined in the
:hosts role of the Capfile
* HOST\_ADMIN - name of admin user on all hosts (NOT root). Defaults to 'host_admin'
* LOCAL\_ADMIN - name of admin user on local (maybe development or staging site)
who has the authority to run commands on all hosts. Should be able to ssh into
both HOST\_ADMIN and 'root' on all hosts via public key logins. Defaults to
'local\_admin'
* LOCAL\_ADMIN_EMAIL - email address of admin who should receive notifications
from all hosts - typically from 'monit'. Defaults to 'local\_admin@example.com'

For site installation testing:

* SITE - name of site. Should satisfy [a-z][_a-z0-9]*  Defaults to 'site'
* SITE_USER - name of user who owns the site and is the owner of the proxied
web servers [mongrel or thin]. Defaults to 'site'
* SITE\_BASE_PORT - starting port number for proxied servers. Defaults to 8000
* SITE\_NUM_SERVERS - number of mongrel/thin's to spin up. Default is 3

## Create Account

as HOST_USER

    sudo useradd --comment 'admin for $SITE' --user-group --create-home $SITE_USER
    sudo mkdir /home/${SITE_USER}/.ssh
    sudo cp -R /home/${HOST_ADMIN}/.ssh/authorized_keys /home/${SITE_USER}/.ssh
    sudo chown -R ${SITE_USER} /home/${SITE_USER}/.ssh
    sudo chmod -R u-w /home/${SITE_USER}/.ssh
    sudo chmod -R go-rwx /home/${SITE_USER}/.ssh

## Create Postgresql User

    echo 'create user $SITE_USER createdb;' | psql postgres postgres

    echo "create database $DATABASE with owner $SITE_USER encoding 'utf-8' template template0 ;" | \
        psql postgres postgres

## as SITE_USER

    chmod 744 .
    mkdir sites
    mkdir $SITE
    sudo chgrp http $SITE sites
    sudo chmod 750 $SITE sites
    sudo chmod g+s $SITE sites

### install rvm

    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
    
    Note: if rvm fails on 'cannot create /usr/local/bin/rvm', check to see if /etc/rvmrc
    exists. If it does, it will be sourced by bash and will attempt a global install.

### install ruby 1.9.2
ge
    rvm install 1.9.2
    (wait)
    rvm use 1.9.2 --default
    
### install bundler

    gem install bundler
    
### install and configure thin

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

### create .monitrc file to manage thin server

    TBD - Steal this from Mike Clark's recipes book
    
    
    # check $SITE - cobbled from apache check
    check file $SITE_bin with path /usr/sbin/$SITE
      if failed md5 checksum and
         expect the sum 869b5a36e7f2d553197675fec58c3917 then stop
      if failed permission 755 then stop
      if failed uid root then stop
      if failed gid root then stop
      alert mike@clove.com on {
            checksum, permission, uid, gid # , unmonitor
        } with the mail-format { subject: "/usr/sbin/$SITE modified " }
      group server

    # check $SITE - cobbled from apache check
    check file postmaster_bin with path /usr/bin/postmaster
      if failed md5 checksum and
         expect the sum 13704b8f314a0aa92e7d03557595f2de then stop
      if failed permission 755 then stop
      if failed uid root then stop
      if failed gid root then stop
      alert mike@clove.com on {
            checksum, permission, uid, gid # , unmonitor    } with the mail-format { subject: "/usr/sbin/postmaster modified " }
      group server

    
