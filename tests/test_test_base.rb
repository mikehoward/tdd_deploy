$:.unshift File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy/test_base'
require 'tdd_deploy/server'

class TestTestBaseCase < Test::Unit::TestCase
  def setup
    TddDeploy::Server.new.load_all_tests
  end
  
  def teardown
    TddDeploy::Server.new.load_all_tests
  end

  def test_require_subclass
    assert TddDeploy::TestBase.children.include?(TddDeploy::HostConnection), "children must contain TddDeploy::HostConnection"
  end
  
  def test_flush_children_methods
    children_before = TddDeploy::TestBase.children
    TddDeploy::TestBase.children.each do |child|
      assert_not_equal [], child.instance_methods(false), "child #{child} should have methods"
    end
    TddDeploy::TestBase.flush_children_methods
    assert_equal children_before, TddDeploy::TestBase.children, "flush_children should not change children Array"
    TddDeploy::TestBase.children.each do |child|
      assert_equal [], child.instance_methods(false), "Each child should not have any methods"
    end
    
    TddDeploy::Server.new.load_all_tests
    TddDeploy::TestBase.children.each do |child|
      assert_not_equal [], child.instance_methods(false), "child #{child} should have methods after reloading"
    end
  end
end
