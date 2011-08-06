$:.unshift File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy'

class TestSetEnvTestCase < Test::Unit::TestCase
  include TddDeploy
  
  def setup
    self.class.reset_env
  end
  
  def test_true
    assert true, "true is true"
  end
end
