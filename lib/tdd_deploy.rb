$:.unshift File.expand_path('..', __FILE__)

require 'tdd_deploy/base'
require 'tdd_deploy/assertions'
require 'tdd_deploy/deploy_test_methods'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/version'

if defined? Rails
  require 'tdd_deploy/railengine'
end

# = TddDeploy
#
# TddDeploy provides methods for testing the provisioning of remote hosts
# and Rails instances running as virtual hosts
#
# Tests are simple to write.
#
#   Step 1: require 'tdd_deploy' and then subclass TddDeploy::Base
#   Step 2: write tests using the methods: *run_on_all_hosts* and *run_on_all_hosts_as*
#   Step 3: run tests and fix installation until all tests pass
#
# These tests do not guarantee that anything will work. They only test to see if the files
# are installed and that communication works to all hosts the site runs on.
#
# see the tdd_deploy gem Readme file for more information.
#
# see HostSetup.md and SiteSetup.md for info on setting up Arch linux servers and Rails
# apps running on them. Both of these documents are out of sync with respect to the rest
# of tdd_deploy: make the 'obvious' translation between shell script variables and
# tdd_deploy environment keys.

module TddDeploy
end