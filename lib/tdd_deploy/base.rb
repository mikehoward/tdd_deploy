require 'tdd_deploy/assertions'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'
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
# == TddDeploy::Base
#
# TddDeploy::Base is a class which includes all the TddDeploy modules
# and initializes the environment.
#
# it is meant to be subclassed for individual host and site tests.
#
#  class HostFacilityTest < TddDeploy::Base
#     def test_for_file
#       deploy_test_on_all_hosts_as user_id, match_string_or_regx, err_msg { command }
#     end
#     etc
#   end
module TddDeploy
  class Base
    include TddDeploy::Assertions
    include TddDeploy::Environ
    include TddDeploy::RunMethods
    include TddDeploy::DeployTestMethods

    # args are ignored - they are here in case a derived class needs some
    def initialize *args
      read_env || reset_env
    end
  end
end
