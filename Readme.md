# TddDeploy

NOTE: version 0.1.0 is not useable

**This is a prototype. It works, but is ugly and almost certainly the wrong design.**

*I think there is room in host provisioning and site installation for TDD tools which
are independent of the provisioning framework - which is what TddDeploy attempts to
be.*

TddDeploy implements command execution on remote hosts to aid in host provisioning and
deployment of multiple Rails applications on one or more hosts.

It is designed to complement Capistrano, so it follows Capistrano's opinions:

      Capistrano makes a few assumptions about your servers. In order to use Capistrano, you will need to comply
      with these assumptions:

      * You are using SSH to access your remote machines. Telnet and FTP are not supported.
      * Your remote servers have a POSIX-compatible shell installed. The shell must be called “sh” and must
        reside in the default system path.
      * If you are using passwords to access your servers, they must all have the same password. Because this
        is not generally a good idea, the preferred way of accessing your servers is with a public key. Make
        sure you’ve got a good passphrase on your key.

While, Capistrano focuses on deploying the Rails application, TddDeploy focuses on validating the
configuration of both the deployment host(s) and a Rails application.

* [Installation](#installation)
* [Uninstall](#uninstall)
* [Assumptions](#tdddeploy_assumptions)
* [Data which is managed](#data_managed)
* [Tests](#tests)
* [Command Line Utilities](#utilities)

## How to Use

* go to the root of you Rails App
* Install the gem
* run the install rake task
* at a terminal, run 'tdd\_deploy\_context'. It's ugly, but works. The variables you need
to set are described in [Data](#data_managed)
* look over the tests in '/lib/tdd\_deploy'. They should be pretty self explanatory.
To change them, move to /lib/tdd\_deploy/local\_tests and hack away. Copy and hack to
add more tests. [hint: if you do this, you should copy or move everything .../local\_tests (and
maybe run rake tdd\_deploy:flush\_gem\_tests)]
* open a terminal and start the server.
* open a browser window and visit 'localhost:9292'.

NOTES:

* The server reloads the configuration when you change it
* The server does NOT pick up new or modified tests, so you have to restart it.

## Installation

    gem install tdd_deploy
    
    (add to your Gemfile)
    
    bundle
    
    rake tdd_deploy:install_gem_tests # which copies the existing tests to 'lib/tdd_deploy'

    tdd_deploy_context # fill in your data
    
    tdd_deploy_server  # starts server
    
To add or modify tests, copy a similar test to *lib/tdd\_deploy/local_tests* and hack
it. Feel free to delete any tests you don't want from *lib/tdd\_deploy/hosts\_tests*
and *lib/tdd\_deploy/site\_tests*.

## Uninstall

    # remove all tests from lib/tdd_deploy/hosts_tests & lib/tdd_deploy/site_tests
    rake tdd_deploy:uninstall
    
    # optionally remove created config files
    rm -rf 
    
    (remove from Gemfile)
    
    bundle

## TddDeploy Assumptions

The assumptions are all implemented in variables which define the provisioning and
deployment environment. TddDeploy refers to them as 'environment' variables, but to
avoid confusion, we'll call them 'context variables'.

## Data Managed

All variables are saved in a file named **site\_host\_setup.env** which will (typically)
be in the root directory of the Rails application. The format is 'name=value'.

Three kinds of values:

* int - which are integers
* string - which are strings - trimmed of leading and trailing white space
* lists - comma (with optional white space) separated words. Words may not contain
embedded white space.

### Provisioning Context Variables

* host_admin - string - this is a user defined on all remote hosts. It has sudo access as 'root',
but it is not 'root'

* local_admin - string - this is a user defined on the host which tests the provisioning. It could
be a staging host or a development host or something else. The host is 'local' in the sense
that it is not a public facing host.

    **Important:** This user must be able to ssh into each remote host as both _host\_admin_ and as _root_.
    
* local\_admin\_email - string - this is the email address of someone who should receive monitoring
reports. [This is in to support _monit_ monitoring software - which will email event
notifications]

* ssh\_timeout - int - number of seconds before an ssh command times out and is flagged as
a failure.

* hosts - list - this is a list of all the hosts. This list is used to check that the communication
works.
* web\_hosts - list - a list of hosts which run web servers
* db\_hosts - list - a list of hosts which run database servers
* balance\_hosts - list - a list of hosts which do load balancing

It's easer to understand assumptions if they relate to a concrete example. So, assume we
are setting up a Rails app on hosts 'foo', 'bar' and 'baz'. Their duties are:

* 'foo' - runs the web server and load balances (somehow) between itself and 'baz'
* 'bar' - runs the master database server
* 'baz' - runs both a web server and the slave database server.

So in this setup:

* hosts = foo,bar,baz
* web\_hosts = foo,baz
* db\_hosts = bar,baz
* balance_hosts = foo

### Site Deployment Context Variables

* site - string - name of the site. Should satisfy [a-z][a-z0-9_]+, but this isn't checked.
Defaults to 'site'
* site\_path - string - absolute path to DocumentRoot of site.  No default.
* site\_url - string - URL of site [typically something like www.example.com].
This string is not checked, but should be a single domain name.
No default.
* site\_aliases - string - as few or many aliases for the site\_url. No default
* site\_user - string - name of user on all remote **web\_hosts** which host the app.
We assume that this user will own all installations of the application on all the **web\_hosts**
and will be the database user which owns and connects to the database on all the **db\_hosts**.
Defaults to 'site\_user'.
* site\_base\_port - int - TddDeploy assumes that the Rails app will fronted by a reverse proxy
\- nginx or apache - and will run a small pack of *thin* or *mongrel* servers. The **site\_base\_port**
is the beginning of the block of ports used by the pack of servers.
* site\_num\_servers - int - number of *thin* or *mongrel* (or whatever) servers which the app
expects to have running.

## Tests

You must install the tests by running **rake tdd\_deploy:install**. This copies the
tests in the gem to your app's directory - into *lib/tdd\_deploy/*.

Tests live in *lib/tdd_deploy* in one of three subdirectories:

* lib/tdd\_deploy/host_tests - copies of my tests for a host running the Arch linux distribution
* lib/tdd\_deploy/site_tests - cursory tests for my personal site setup
* lib/tdd\_deploy/local\_tests - initially empty. Create tests there by copying and hacking.
The **uninstall** rake task does *not* remove tests from this directory.

## Utilities

There are two utilities:

* tdd\_deploy\_context - a command line utility for managing Host and Site context variables
* tdd\_deploy\_server - a command line utility which starts up the test results server on localhost,
port 9292.
