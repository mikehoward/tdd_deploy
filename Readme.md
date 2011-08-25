# TddDeploy - VERSION

**This is a prototype. It works, but isn't pretty and polished.**

**NOTE: HTML copies of this and two more documents are in lib/tdd\_deploy/doc. The other
two documents are my personal notes on setting up hosts and sites. YMMV.**

TddDeploy supports deployment configuration management and black box testing of deployment
hosts.

It is designed to complement Capistrano

It does this by:

* defining and managing an opinionated set of data which specify hosts and user accounts
* automate testing of remote hosts via running commands - locally and remotely via ssh
* provides a rack compatible local web server to run the tests
* as a bonus, it also creates host & site specific configuration files from erb template.

It is designed to complement Capistrano - hence the opinionated:

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

## Shortcuts

* [How to Use](#how_to_use)
* [Installation](#installation)
* [Uninstall](#uninstall)
* [Assumptions](#tdddeploy_assumptions)
* [Data which is managed](#data_managed)
* [Deployment Tests](#tests)
* [Command Line Utilities](#utilities)

<h2 id="how_to_use">How to Use</h2>

The short version is: install it, edit the variables (using `tdd_deploy_context`), start
the server (on localhost:9292) (using `tdd_deploy_server`) and hack until things turn
green.

The longer version is:

* Install the gem
* go to the root of you app
* run the install rake task
* at a terminal, run 'tdd\_deploy\_context'. It's ugly, but works. The variables you need
to set are described in [Data](#data_managed)
* look over the tests in '/lib/tdd\_deploy'. They should be pretty self explanatory.
To change them, move to /lib/tdd\_deploy/local\_tests and hack away. Copy and hack to
add more tests. [hint: if you do this, you should copy or move everything .../local\_tests (and
maybe run rake tdd\_deploy:flush\_gem\_tests)]
* edit your Capistrano Capfile - or config/deploy.rb if you're running Railse
* muck with the deployment files in lib/tdd\_deploy/site-erb. There are files for each class
of hosts. add, edit, etc files as you see fit.
* open a terminal and start the server.
* open a browser window and visit 'localhost:9292'.
* build your deployment site-config filees by clicking the 'Run Configurator' button.
* hack your Capistrano config/deploy.rb to copy the files to the appropriate roles.
* run Capistrano to deploy
* muck with your deployment sites until all tests pass

Note: The server is supposed to automatically pick up new or modified tests, but
you may have to restart it when you change or add one

<h2 id="installation">Installation</h2>

    gem install tdd_deploy
    
    (add to your Gemfile)
    
    bundle
    
    rake tdd_deploy:install_gem_tests # which copies the existing tests to 'lib/tdd_deploy'

    tdd_deploy_context # fill in your data
    
    tdd_deploy_server  # starts server
    
To add or modify tests, copy a similar test to *lib/tdd\_deploy/local_tests* and hack
it. Feel free to delete any tests you don't want from *lib/tdd\_deploy/hosts\_tests*
and *lib/tdd\_deploy/site\_tests*.

<h2 id="uninstall">Uninstall</h2>

    # remove all tests from lib/tdd_deploy/hosts_tests & lib/tdd_deploy/site_tests
    rake tdd_deploy:uninstall
    
    # optionally remove created config files
    rm -rf 
    
    (remove from Gemfile)
    
    bundle

<h2 id="tdddeploy_assumptions">TddDeploy Assumptions</h2>

The assumptions are all implemented in variables which define the provisioning and
deployment environment. TddDeploy refers to them as 'environment' variables, but to
avoid confusion, we'll call them 'context variables'.

<h2 id="data_managed">Data Managed</h2>

All variables are saved in a file named **site\_host\_setup.env** which will (typically)
be in the root directory of the Rails application. The format is 'name=value'.

Three kinds of values:

* int - which are integers
* string - which are strings - trimmed of leading and trailing white space
* lists - comma (with optional white space) separated words. Words may not contain
embedded white space. [internally, lists are Ruby Arrays]
* pseudo - The pseudo variables are 'hosts' - which is a convenience variable &
variables taken from the roles defined in your Capistrano Capfile (or deploy)

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

* app\_hosts - list - list of hosts which are running a ruby app
* balance\_hosts - list - a list of hosts which do load balancing
* db\_hosts - list - a list of hosts which run database servers
* web\_hosts - list - a list of hosts which run web servers

* hosts - pseudo-list - this is a list of all the hosts. This list is used to check that the communication
works. **hosts** is kind of a convenience. It is computed as the unique sum of the other hosts
lists. It only shows up as an assignable variable if all three of the other lists are identical.
It can always be used to reference all hosts, but cannot be assigned to if any list differs.

It's easer to understand assumptions if they relate to a concrete example. So, assume we
are setting up a Rails app on hosts 'foo', 'bar' and 'baz'. Their duties are:

* 'app1' & 'app2' - run the Rails app
* 'foo' - runs the web server and load balances (somehow) between itself and 'baz'
* 'bar' - runs the master database server
* 'baz' - runs both a web server and the slave database server.

So in this setup:

* hosts = foo,bar,baz
* app\_hosts = app1,app2
* web\_hosts = foo,baz
* db\_hosts = bar,baz
* balance\_hosts = foo

### Site Deployment Context Variables

* capfile\_paths - list - list of paths to Capistrano recipe files. Defaults to './config/deploy.rb',
which is generally right for Rails apps.
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

In addition there are four (4) _pseudo_ variables. These are read-only and take their values
from your Capistrano configuration

* app - hosts defined in the 'app' role
* db - hosts defined in the 'db' role
* web - hosts defined in the 'web' role
* migration\_hosts - hosts defened in the 'db' role which have the option :primary set to true.

<h2 id="tests">Deployment Tests</h2>

You must install the tests by running **rake tdd\_deploy:install**. This copies the
tests in the gem to your app's directory - into *lib/tdd\_deploy/*.

Tests live in *lib/tdd_deploy* in one of three subdirectories:

* lib/tdd\_deploy/host_tests - copies of my tests for a host running the Arch linux distribution
* lib/tdd\_deploy/site_tests - cursory tests for my personal site setup
* lib/tdd\_deploy/local\_tests - initially empty. Create tests there by copying and hacking.
The **uninstall** rake task does *not* remove tests from this directory.

<h2 id="utilities">Utilities</h2>

There are two utilities:

* tdd\_deploy\_context - a command line utility for managing Host and Site context variables
* tdd\_deploy\_server - a command line utility which starts up the test results server on localhost,
port 9292.

<h2>Code Tests</h2>

The code is tested against an Arch linux server running as a virtual host on my machine with
my setup. YMMV.
