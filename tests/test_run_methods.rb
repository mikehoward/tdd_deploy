$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'

class RunMethodsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  include TddDeploy::RunMethods

  def setup
    self.reset_env
    self.set_env :hosts => 'arch,ubuntu', :host_admin => 'mike', :ssh_timeout => 2
  end

  def test_ping_host
    assert ping_host('localhost'), 'can ping local host'
    assert ping_host('arch'), 'can ping arch'
    refute ping_host('ubuntu'), 'cannot ping non-running host'
    refute ping_host('non-existent-host'), 'cannot ping non-existent-host'
  end

  def test_run_on_a_host_as
    stdout, stderr, cmd = run_on_a_host_as 'mike', 'arch', 'pwd'
    assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
    assert_nil stderr, "should not return error if can connect to host"
    assert_equal 'pwd', cmd, 'cmd should be pwd'
      
    stdout, stderr = run_on_a_host_as 'mike', 'no-host', 'pwd'
    refute_equal "/home/mike\n", stdout, "should not return home directory for bad host name"
    refute_nil stderr, "should return an error message for bad host name"
    assert_equal 'pwd', cmd, 'cmd should be pwd'
      
    stdout, stderr = run_on_a_host_as 'no-user', 'arch', 'pwd'
    refute_equal "/home/mike\n", stdout, "should not return home directory for bad user name"
    refute_nil stderr, "should return an error message for bad user name"
  end
  
  def test_run_on_a_host_as
    stdout, stderr, cmd = run_on_a_host_as 'mike', 'arch' do
      'pwd'
    end
    assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
    assert_nil stderr, "should not return error if can connect to host"
    assert_equal 'pwd', cmd, 'cmd should be pwd'
  end
    
  def test_run_on_hosts_as
    result = run_on_hosts_as 'mike', ['arch', 'arch'], 'pwd'
    assert_not_nil result, "run_on_hosts_as should not return nil"
    assert result.is_a?(Hash), "run_on_hosts_as should return an Hash"
    assert_equal ["/home/mike\n", nil, 'pwd'], result['arch'], "Result['arch'] should have command results"
    assert_equal 1, result.length, "result length should be 1, not 2"
  end

  def test_run_on_hosts_as_with_string_for_hosts_list
    result = run_on_hosts_as 'mike', 'arch', 'pwd'
    assert_not_nil result, "result should work with a single string for a host list"
    assert_equal ["/home/mike\n", nil, 'pwd'], result['arch'], "run_on_all_hosts_as should work with string for host list"
  end
  
  def test_run_on_all_hosts_as
    results = run_on_all_hosts_as('root') { 'pwd'}
    refute_nil results, "results should not be nil"
    assert results.is_a?(Hash), "results should be a Hash"
    assert_equal 2, results.size, "results should have two entries"
    
    assert_equal "/root\n", results['arch'][0], "should run correctly on arch"
    assert_nil results['arch'][1], "no errors on arch"
    assert_equal results['arch'][2], 'pwd', 'cmd should be pwd'
    
    assert_nil results['ubuntu'][0], "no stdout for ubuntu"
    refute_nil results['ubuntu'][1], 'failure message for ubuntu'
    assert_equal results['ubuntu'][2], 'pwd', 'cmd should be pwd'
  end
  
  def test_run_on_all_hosts
    results = run_on_all_hosts { 'pwd' }
  
    assert_equal "/home/mike\n", results['arch'][0], "should run correctly on arch"
    assert_nil results['arch'][1], "no errors on arch"
    assert_equal results['arch'][2], 'pwd', 'cmd should be pwd'
    
    assert_nil results['ubuntu'][0], "no stdout for ubuntu"
    refute_nil results['ubuntu'][1], 'failure message for ubuntu'
    assert_equal results['ubuntu'][2], 'pwd', 'cmd should be pwd'
  end
  
  def test_run_locally
    stdout, stderr, cmd = run_locally { 'echo foo' }
    assert_equal "foo\n", stdout, "echo foo should echo foo\\n"
    assert_nil stderr, "stderr should be nil"
    assert_equal 'echo foo', cmd, "cmd should be 'echo foo'"
  
    stdout, stderr, cmd = run_locally { 'bad-command foo' }
    assert_nil stdout, "stdout should be nil for bad command"
    refute_nil stderr, "stderr should not be nil"
    assert_equal 'bad-command foo', cmd, "cmd should be 'bad-command foo'"
  end
  
  def test_run_locally_with_input
    input_text = "one line of text\n"
    stdout, stderr, cmd = run_locally(input_text) { 'cat -' }
    assert_equal input_text, stdout, "command should echo input: '#{input_text}"
    assert_nil stderr, "command should not generate errs"
  end
end