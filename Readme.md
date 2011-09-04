# TddDeploy - 0.1.11.pre1

**This is a prototype. It works, but isn't pretty and polished.**

**NOTE: Detailed use and Installation instructions are in `lib/tdd_deploy/doc/Overview.md`.
There are also two more documents which are my personal notes on setting up hosts and sites. YMMV.**

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

# Branch Information

**master** is more-or-less stable. The more-or-less is that this project is still in flux.
It matches the current version which is on rubygems.org and is up to date with the latest
tagged version of the **0-1** branch.

**0-1** is current development. I'm trying to remember to tag the version with 'pre<something>',
but there are no guarantees.

**0-0** is dead ended.

# Notes on Unit Tests

These tests run on my system with a virtual host running Arch Linux with host name 'arch'
and a bunch of accounts. The tests won't work without a conforming setup.
