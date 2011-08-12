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
    stdout, stderr = capture_io do
      @assertion_helper.announce_test_results
    end
    assert_match /All Tests Passed/i, stdout, "announcement should include 1 Failure"
  end
  
  def test_assert_equal
    assert @assertion_helper.assert_equal(true, true, "true is still true"), "true is true"
  end
  
  def test_assert_match
    assert @assertion_helper.assert_match('^foo$', 'foo', 'foo is not bar'), 'foo is not bar'
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
  
  def test_fail
    refute @assertion_helper.fail('fail returns false'), 'fail returns false'
  end
  
  def test_announcement
    refute @assertion_helper.assert(false, 'forcing a failure'), 'forcing a failure'
    stdout, stderr = capture_io do
      @assertion_helper.announce_test_results
    end
    assert_match /1 Failed/, stdout, "announcement should include 1 Failure"
  end
end