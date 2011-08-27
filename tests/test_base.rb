$:.unshift File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy/base'

module TestBase
  class Foo < TddDeploy::Base
  end

  class Bar < TddDeploy::Base
  end
end

class TestBaseTestCase < Test::Unit::TestCase
  def test_tdd_deploy_base_children
    assert_equal TddDeploy::Base, TestBase::Foo.superclass, "Foo is a child of TddDeploy::Base"
  end
end
