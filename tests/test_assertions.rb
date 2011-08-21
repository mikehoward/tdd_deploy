$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/assertions'

class AssertionHelper
  include TddDeploy::Assertions
end

class TestTddDeployAssertionsTestCase < Test::Unit::TestCase
  
  def setup
    @assertion_helper = AssertionHelper.new
    @assertion_helper.reset_tests
  end
  
  def teardown
    @assertion_helper = nil
  end
  
  def test_pass_passes
    assert @assertion_helper.pass('key', 'passing message'), 'pass passes'
    assert @assertion_helper.test_results['key'].is_a?(Array), "test_results[key] should be an Array"
    assert_equal 1, @assertion_helper.test_results['key'].length, "There should be a test_results[key]"
    assert_equal true, @assertion_helper.test_results['key'].first[0], "pass should be a passing result"
    assert_match /passing message/, @assertion_helper.test_results['key'].first[1], "pass should have the right success message"
  end

  def test_fail_fails
    refute @assertion_helper.fail('key', 'failing message'), 'fail fails'
    assert @assertion_helper.test_results['key'].is_a?(Array), "test_results[key] should be an Array"
    assert_equal 1, @assertion_helper.test_results['key'].length, "There should be a test_results[key]"
    assert_equal false, @assertion_helper.test_results['key'].first[0], "pass should be a passing result"
    assert_match /failing message/, @assertion_helper.test_results['key'].first[1], "pass should have the right success message"
  end
  
  def test_keying_tests
    @assertion_helper.pass('key1', 'key1 assertion message')
    @assertion_helper.fail('key2', 'key2 assertion message')
    
    assert @assertion_helper.test_results.keys.include?('key1'), "test messages includes key1"
    assert @assertion_helper.test_results.keys.include?('key2'), "test messages includes key2"
    
    assert_equal 1, @assertion_helper.test_count('key1'), "one test recorded under 'key1'"
    assert_equal 0, @assertion_helper.failure_count('key1'), "0 failures recorded under 'key1'"
    
    assert_equal 1, @assertion_helper.test_count('key2'), "one test recorded under 'key2'"
    assert_equal 1, @assertion_helper.failure_count('key2'), "1 failure recorded under 'key2'"
  
    assert_equal [], @assertion_helper.failure_messages('key1'), "falure_messages('key1') is nil"
    assert_not_equal [], @assertion_helper.failure_messages('key2'), "falure_messages('key1') is not an empty array"
    
    assert_no_match(/key1/, @assertion_helper.test_results['key2'].join('\n'), 'test messages for key2 do not contain key1')
  end
  
  def test_assert_true_passes
    assert @assertion_helper.assert('key', true, 'true is true'), 'true tests true'
    assert @assertion_helper.test_messages('key').first[0], "asserting 'true' passes"
    assert_match(/Pass/i, @assertion_helper.formatted_test_results, "test messagess should include 'Pass'")
  end
  
  def test_assert_false_fails
    refute @assertion_helper.assert('key', false, 'true is true'), "false tests false"
    refute @assertion_helper.test_messages('key').first[0], "asserting 'false' fails"
    assert_match /Fail/i, @assertion_helper.formatted_test_results, "test messages should include 'Fail'"
  end
  
  def test_assert_equal
    assert @assertion_helper.assert_equal('key', true, true, "true is still true"), "true is true"
  end
  
  def test_assert_match
    assert @assertion_helper.assert_match('key', '^foo$', 'foo', 'foo is not bar'), 'foo is not bar'
  end
  
  def test_assert_nil
    assert @assertion_helper.assert_nil('key', nil, "nil is nil"), "nil is nil"
  end
  
  def test_assert_not_nil
    assert @assertion_helper.assert_not_nil('key', 'foo', 'foo is not nil'), 'foo is not nil'
  end
  
  def test_assert_raises
    assert @assertion_helper.assert_raises(Exception, '1/0 raises something') { 1/0 }, '1/0 raises something'
  end
  
  def test_refute
    assert @assertion_helper.refute('key', false, 'false is false'), 'false is false'
  end
  
  def test_refute_equal
    assert @assertion_helper.refute_equal('key', false, true, "false is not true"), "false is not true"
  end
  
  def test_total_failures
    assert_equal 0, @assertion_helper.total_failures, "no tests results in 0 total failures"
    @assertion_helper.fail 'key', 'forcing a failure'
    assert_equal 1, @assertion_helper.total_failures, "failing creates a failure"
    assert_equal @assertion_helper.total_failures, @assertion_helper.total_tests, "failures == tests"
    @assertion_helper.fail 'key', 'forcing a failure'
    assert_equal 2, @assertion_helper.total_failures, "failing creates a failure"
    
    @assertion_helper.pass 'key', 'forcing a pass'
    assert_equal 2, @assertion_helper.total_failures, "failing creates a failure"
    assert_equal 3, @assertion_helper.total_tests, "passing creates another test"
  end
end