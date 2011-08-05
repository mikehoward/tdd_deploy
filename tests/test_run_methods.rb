$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy'

class RunMethodsTestCase < Test::Unit::TestCase
  include TddDeploy

  def setup
    self.hosts = ['arch', 'ubuntu']
    self.host_admin = 'mike'
    self.ssh_timeout = 2
  end
  
  def test_run_in_ssh_session_as
    stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch' do
      'pwd'
    end
    assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
    assert_nil stderr, "should not return error if can connect to host"
    assert_equal 'pwd', cmd, 'cmd should be pwd'

    stdout, stderr = run_in_ssh_session_as 'mike', 'no-host' do
      'pwd'
    end
    refute_equal "/home/mike\n", stdout, "should not return home directory for bad host name"
    refute_nil stderr, "should return an error message for bad host name"
    assert_equal 'pwd', cmd, 'cmd should be pwd'

    stdout, stderr = run_in_ssh_session_as 'no-user', 'arch' do
      'pwd'
    end
    refute_equal "/home/mike\n", stdout, "should not return home directory for bad user name"
    refute_nil stderr, "should return an error message for bad user name"
  end
  
  def test_run_in_ssh_session
    stdout, stderr, cmd = run_in_ssh_session('arch') { 'pwd' }
    assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
    assert_nil stderr, "should not return error if can connect to host"
    assert_equal 'pwd', cmd, 'cmd should be pwd'
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
end