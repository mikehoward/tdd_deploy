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
    assert TddDeploy::Base.children.include?(TestBase::Foo), "TddDeploy::Base.children should contain TestBase::Foo"
    assert TddDeploy::Base.children.include?(TestBase::Bar), "TddDeploy::Base.children should contain TestBase::Bar"
  end
end
