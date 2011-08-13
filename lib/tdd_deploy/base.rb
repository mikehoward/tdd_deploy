
require 'tdd_deploy/assertions'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'

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
