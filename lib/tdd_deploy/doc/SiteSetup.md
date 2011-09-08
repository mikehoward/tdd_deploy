# Site Setup.

Assumes running on Linode - but should translate
Assumes Arch linux - but should translate

The rest of this refers to these three variables. But, the
code fragments won't necessarily work.

    export SITE=
    export DATABASE=$SITE
    export SITE_USER=$SITE
    export PASSWORD=<something>
    
## config/deploy.rb adjustments

After running 'capify', edit 'config/deploy.rb' and add these lines:

    require 'bundler/capistrano'
    
    set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'
    set :user, SITE_USER  # this tells Capistrano who to ssh in as
    set :use_sudo, false  # this will let Capistrano run as your user w/o attempting to use sudo.
    set :scm, :git   # you are using github.com?
    set :repository, "git@github.com:...."  # the github readonly path to our repository
    set :deploy_to, '...'  # set this to the **parent** directory of the path you use for site_app_root.
    # If you have /home/foo/foobar/current as site_app_root, then set :deploy_to to '/home/foo/foobar'

See [below](#capistrano_ness) for more details.

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
* SITE\_USER - name of user who owns the site and is the owner of the proxied
web servers [mongrel or thin]. Defaults to 'site'
* SITE\_BASE_PORT - starting port number for proxied servers. Defaults to 8000
* SITE\_NUM_SERVERS - number of mongrel/thin's to spin up. Default is 3

## Create Account

as HOST_USER

    sudo useradd --comment 'admin for $SITE' --user-group --create-home $SITE_USER
    sudo chgrp http ~${SITE_USER}
    sudo chmod 710  ~${SITE_USER}
    sudo mkdir /home/${SITE_USER}/.ssh
    sudo cp -R /home/${HOST_ADMIN}/.ssh/authorized_keys /home/${SITE_USER}/.ssh
    sudo chown -R ${SITE_USER} /home/${SITE_USER}/.ssh
    sudo chmod -R go-rwx /home/${SITE_USER}/.ssh
    sudo -u ${SITE_USER} ssh-keygen
    
when you get done you should see:

    sudo ls -ld ~${SITE_USER}  # should be drwx--x--- and more stuff
    sudo ls -ld ~${SITE_USER}/.ssh  # should look like drwx------ and more stuff
    sudo ls -lR ~${SITE_USER}/.ssh  # should look like -rw------- for all listed files
      (it's OK if id_rsa.pub is -rw-r--r--)

## Create Postgresql User

    echo "create user $SITE_USER createdb;" | psql postgres postgres

    echo "create database $DATABASE with owner $SITE_USER encoding 'utf-8' template template0 ;" | \
        psql postgres postgres

## as SITE_USER

    chmod 701 .   # this lets 'other' userid's search your site. 
    mkdir sites
    mkdir $SITE
    sudo chgrp http $SITE sites
    sudo chmod 755 $SITE sites
    sudo chmod g+s $SITE sites

### install rvm

    do an `ls -a` and make sure you have a `.bash_profile` and `.bashrc` file.

    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

    follow the instructions and append the `[[ ....]] && ... ` to your `.bashrc` file
    
    log out as site user
    
    log back in as SITE_USER and type `rvm`. You see a bunch of stuff. You see something
    like `rvm not found`, then you have a problem you need to fix. So fix it.
    
#### rvm installation problems

if rvm fails on 'cannot create /usr/local/bin/rvm', check to see if /etc/rvmrc
exists. If it does, it will be sourced by bash and will attempt a global install.



### install ruby 1.9.2

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

## Capistrano-ness

Several things need to be set up in the Capistrano deployment file (config/deploy.rb)

Add **require 'bundler/capistrano'** at the top of the file.

* set :user, $SITE\_USER  # this tells Capistrano who to ssh in as
* set :use\_sudo, false  # this will let Capistrano run as your user w/o attempting to use sudo.
* set :bundle\_cmd, '~/.rvm/bin/rvm exec bundle'  # this runs the bundler using your local rvm'ed ruby
* set :scm, :git   # you are using github.com?
* set :repository, "git@github.com:...."  # the github readonly path to our repository
* set :deploy\_to, '...'  # set this to the **parent** directory of the path you use for site\_app\_root.
If you have /home/foo/foobar/current as site\_app\_root, then set :deploy\_to to '/home/foo/foobar'

**Note:** bundler runs fine from the command line, but Capistrano runs commands as a headless
shell. This means it runs in a different environment than when you run interactively. Specifically,
it doesn't execute all the nice '.bash...' files do it doesn't know about 'rvm' unless you tell it
explicitly. This means we have to set the ':bundle\_cmd'.

### setting up github.com so you can deploy to your host

Read the Capistrano Doc

* [Getting Started](https://github.com/capistrano/capistrano/wiki/2.x-Getting-Started)
* [From the Beginning](https://github.com/capistrano/capistrano/wiki/2.x-From-The-Beginning)
* [Github: Deploy with Capistrano](http://help.github.com/deploy-with-capistrano/) - This presents
something different from what follows below. I haven't tried it yet, so YMMV.

You're going to deploying from a private repo on github.com, so read up on Deployment Keys:

* Read the stuff on github.com [Help](http://help.github.com/deploy-keys/)
* Go to your repo, then click Admin -> Deploy Keys and add two keys: one for your host and one
for the site account.

Your user may not have a key yet, so log on as your site user and run **ssh-keygen**. This creates
two keys in ~/.ssh/. Copy-and-paste the public one into a separate deployment key for your site
user.

SITE_USER will pull down your site from the github.com repository using ssh - which will fail
the first time because SITE_USER's .ssh/knownhosts doesn't know about github. You fix that
by attempting `ssh github.com` and answering 'Yes' when ssh asks you whether to trust
the host or not. Then your login will fail, but github.com is now a known host, so deployment
will work.

### Start kicking the Capistrano tires

Make sure your site app is checked in on github.com and then start 'deploying'.

Every time you run a 'cap deploy:...' command, actually READ the messages. If you see the
word 'fail' then it didn't work and Capistrano 'rolled back'. This is a good thing, but it means
you need to fix something.

* cap deploy:setup # this sets up your host with the 'right' directory structure.
* cap deploy:check # this will check your deployment for sanity, but it still may not work
* cap deploy:update # this actually copies your code to your host and runs bundler on Gemfile.
If anything isn't set up right - deployment keys or bundler executable or Gemfile - it will fail
and roll everything back.
* run the Configurator and install Site Specials and Site Config using **tdd\_deploy**. Once
Capistrano has the directories set up, you can install the nginx.conf, monitrc, etc files.

## Future Deployments

You will deploy using `cap deploy`.

**NOTE:** if you don't copy the stuff in lib/tdd\_deploy/app\_hosts/config to the `config` directory
and include them in you git repository, you will need to _reinstall_ them every time
you do a deployment. But then, if you do and you change something, you'll need to - well, figure
it out.

## After First Deployment

You may need to run rake db:migrate by hand:

    cd ~${SITE_USER}/${SITE}/current
    
    bundle exec rake RAILS_ENV=production db:migrate

## Things which can go wrong

* nginx gets permission error accessing static assets (css files, images, javascript): check
the permission on SITE\_USER home directory (and all the directories all the way down). All
the directories must be serachable (the right most permission bit [as in 701]) and the file
must be readable by the nginx user. If you have set your home directory group to 'http' (the
nginx user on Arch linux), then your home group permissions should be 710. If not, then
use 701 (full access to SITE\_USER, nothing on group, and search for 'other')
