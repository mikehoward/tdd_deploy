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
#       deploy_test_on_hosts_as user_id, match_string_or_regx, err_msg { command }
#     end
#     etc
#   end
#
#  NOTE: Derived classes which provide an **initialize** method should call super
#  to ensure that the environment is set. See TddDeploy::Base to see what the
#  parent initializer does.

module TddDeploy
  class Base
    include TddDeploy::Assertions
    include TddDeploy::Environ
    include TddDeploy::RunMethods
    include TddDeploy::DeployTestMethods

    # args are ignored, unless the args.last is a Hash. If it is passed to *set_env*.
    # This allows derived classes to have their own arguments as well as allowing
    # the environment values to modified in a uniform way.
    def initialize *args
      self.env_hash || read_env || reset_env
      set_env(args.pop) if args.last.is_a? Hash
    end
    
    # gather up all descendents so we know what tests to run
    class <<self
      attr_accessor :children
      
      def inherited(child)
        self.children ||= []
        self.children << child
      end
    end
  end
end
