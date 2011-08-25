require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::SmokeTest
  #
  # TddDeploy::SmokeTest is a local test for TddDeploy.
  #
  # it's used to test the testing framework and contains two trivial tests:
  #
  # * return_true
  # * smoke
  class SmokeTest < TddDeploy::Base
    
    # returns true
    def return_true
      true
    end
    
    # returns true
    def smoke
      true
    end
  end
end