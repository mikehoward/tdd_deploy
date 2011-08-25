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
    
### install and configure configuration fragments

After running `rake tdd_deploy:install` there will be a bunch of files
below `lib/tdd_deploy/site-erb`. This directory is arranged as:
`lib/tdd_deploy/site-erb/<host-group>/<dest-dir>`, where:

* `host-group` is one of `app_hosts`, `balance_hosts`, `db_hosts`, or `web_hosts`.
The files under this subdirectory are for all hosts in the designated host group
* `dest-dir` is either:
** `config` - these are files which go into the configuration directory for your app.
For a Rails app, this will be 'config' - or more formally: `site_doc_root/config`
** `site` - these are files which go in `site_special_dir`. They are not expected to
change (too much) between deployments and are expected to be `included` by `monit`
or `nginx`. If you're using `apache` and some other monitoring tool, then you'll
have to do something appropriate.

### Fix Permissions

This configuration scheme expects system applications - such as nginx and monit - to
be able to `include` configuration fragments buried in the home directory of the
user which owns the app.

It's fashionable now to set home directory permissions to 0700, which isn't a problem
for daemons running as root, but it may foul up non-root daemons. So, if everything
passes all tests, but some daemon is not picking up the configuration, try changing the
home & site\_special\_dir permissions to 0755. 
