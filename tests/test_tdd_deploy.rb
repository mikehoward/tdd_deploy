$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy'

class TestTddDeployTestCase < Test::Unit::TestCase
  
  def test_tdd_deploy
    assert defined?(TddDeploy::Assertions), "TddDeploy::Assertions should be defined"
    assert defined?(TddDeploy::Base), "TddDeploy::Base should be defined"
    assert defined?(TddDeploy::DeployTestMethods), "TddDeploy::DeployTestMethods should be defined"
    assert defined?(TddDeploy::Environ), "TddDeploy::Environ should be defined"
    assert defined?(TddDeploy::RunMethods), "TddDeploy::RunMethods should be defined"
    assert defined?(TddDeploy::VERSION), "TddDeploy::VERSION should be defined"
  end
end
