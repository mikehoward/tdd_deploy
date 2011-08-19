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
    assert @assertion_helper.pass('key', 'assertion message'), 'pass passes'
    assert_match /assertion message/, @assertion_helper.test_results, 'pass copies assertion message'
    assert_match /Pass/, @assertion_helper.test_results, 'pass records passing message'
  end

  def test_fail_fails
    refute @assertion_helper.fail('key', 'assertion message'), 'fail fails'
    assert_match /assertion message/, @assertion_helper.test_results, 'fail copies assertion message'
    assert_match /Fail/, @assertion_helper.test_results, 'fail records failing message in test_messages'
    assert_equal 1, @assertion_helper.failure_messages['key'].length, "fail produces a failure message"
  end
  
  def test_keying_tests
    @assertion_helper.pass('key1', 'key1 assertion message')
    @assertion_helper.fail('key2', 'key2 assertion message')
    
    assert @assertion_helper.test_messages.keys.include?('key1'), "test messages includes key1"
    assert @assertion_helper.test_messages.keys.include?('key2'), "test messages includes key2"
    
    assert_equal 1, @assertion_helper.test_count('key1'), "one test recorded under 'key1'"
    assert_equal 0, @assertion_helper.failure_count('key1'), "0 failures recorded under 'key1'"
    
    assert_equal 1, @assertion_helper.test_count('key2'), "one test recorded under 'key2'"
    assert_equal 1, @assertion_helper.failure_count('key2'), "1 failure recorded under 'key2'"

    assert_nil @assertion_helper.failure_messages['key1'], "falure_messages['key1'] is nil"
    assert_not_equal [], @assertion_helper.failure_messages['key2'], "falure_messages['key1'] is not an empty array"
    
    assert_no_match(/key1/, @assertion_helper.test_messages['key2'].join('\n'), 'test messages for key2 do not contain key1')
  end

  def test_assert_true_passes
    assert @assertion_helper.assert('key', true, 'true is true'), 'true tests true'
    assert_match(/Pass/i, @assertion_helper.test_results, "test messagess should include 'Pass'")
  end
  
  def test_assert_false_fails
    refute @assertion_helper.assert('key', false, 'true is true'), "false tests false"
    assert_match /Fail/i, @assertion_helper.test_results, "test messages should include 'Fail'"
    assert_match /1 of 1 Tests Failed/i, @assertion_helper.test_results, "test messages should count 1 failure (#{@assertion_helper.test_messages})"
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
end