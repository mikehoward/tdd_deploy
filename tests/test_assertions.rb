$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/assertions'

class AssertionHelper
  include TddDeploy::Assertions
end

class TestTddDeployAssertionsTestCase < Test::Unit::TestCase
  
  def setup
    @assertion_helper = AssertionHelper.new
  end

  def test_assert
    assert @assertion_helper.assert(true, 'true is true')
  end
  
  def test_assert_equal
    assert @assertion_helper.assert_equal(true, true, "true is still true"), "true is true"
  end
  
  def test_assert_nil
    assert @assertion_helper.assert_nil(nil, "nil is nil"), "nil is nil"
  end
  
  def test_assert_not_nil
    assert @assertion_helper.assert_not_nil('foo', 'foo is not nil'), 'foo is not nil'
  end
  
  def test_assert_raises
    assert @assertion_helper.assert_raises(Exception, '1/0 raises something') { 1/0 }, '1/0 raises something'
  end
  
  def test_refute
    assert @assertion_helper.refute(false, 'false is false'), 'false is false'
  end

  def test_refute_equal
    assert @assertion_helper.refute_equal(false, true, "false is not true"), "false is not true"
  end
  
end