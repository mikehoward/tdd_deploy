require 'tdd_deploy/assertions'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/copy_methods'
require 'tdd_deploy/deploy_test_methods'

module TddDeploy
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
  class Base
    include TddDeploy::Assertions
    include TddDeploy::Environ
    include TddDeploy::RunMethods
    include TddDeploy::CopyMethods
    include TddDeploy::DeployTestMethods

    # args are ignored, unless the args.last is a Hash. If it is passed to *set_env*.
    # This allows derived classes to have their own arguments as well as allowing
    # the environment values to modified in a uniform way.
    def initialize *args
      self.env_hash || read_env || reset_env
      set_env(args.pop) if args.last.is_a? Hash
    end
  end
end
