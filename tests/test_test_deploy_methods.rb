$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class DeployTester
  include TddDeploy::Assertions
  include TddDeploy::Environ
  include TddDeploy::RunMethods
  include TddDeploy::DeployTestMethods
  
  def initialize env_hash
    self.reset_env
    self.set_env env_hash
  end
end

class  DeployTestMethodsTestCase < Test::Unit::TestCase
  def setup
    @tester = DeployTester.new( { :host_admin => 'mike', :local_admin => 'mike', :db_hosts => 'arch', 
        :web_hosts => 'arch', :ssh_timeout => 2 } )
  end
  
  def teardown
    @tester = nil
  end

  def test_default_env
    @tester.reset_env
    assert_equal 'host_admin', @tester.host_admin, "host_admin should be 'host_admin'"
    assert_equal 'local_admin', @tester.local_admin, "local_admin should be 'local_admin'"
    assert_equal 'local_admin@bogus.tld', @tester.local_admin_email, "local_admin_email should be 'local_admin@bogus.tld'"
#    assert_equal 'hosts', @tester.hosts, "hosts should be 'arch'"
    assert_equal ['bar', 'foo'], @tester.hosts, "hosts should be 'bar,foo'"
  end

  def test_custom_env
    @tester.set_env 'host_admin' => 'mike', :local_admin => 'mike', :local_admin_email => 'mike@clove.com'
    assert_equal 'mike', @tester.host_admin, "host_admin should be 'mike'"
    assert_equal 'mike', @tester.local_admin, "local_admin should be 'mike'"
    assert_equal 'mike@clove.com', @tester.local_admin_email, "local_admin_email should be 'mike@clove.com'"
    assert_equal ['arch'], @tester.hosts, "hosts should be 'arch'"
  end
  
  def test_force_failure
    result = @tester.deploy_test_in_ssh_session_as 'no-user', @tester.hosts.first, '/home/no-user', 'should fail with bad user' do
      'pwd'
    end
    refute result, "refute version: should fail with bad userid #{result}"
  end

  def test_deploy_test_in_ssh_session_as
    assert_raises ArgumentError do
      @tester.deploy_test_in_ssh_session_as 'root', @tester.hosts.first, '', 'session catches empty match expression' do
        'uname -a'
      end
      @tester.clear_failure_stats
    end

    tmp = @tester.deploy_test_in_ssh_session_as 'root', @tester.hosts.first, 'no-file-exists', 'generate an error' do
      'ls /usr/no-file-exists'
    end
    # @tester.announce_test_results
    @tester.clear_failure_stats
    refute tmp, "run as root should fail when accessing a non-existent file"

    tmp = @tester.deploy_test_in_ssh_session_as 'root', @tester.hosts.first, "/root", "should run as root on host #{@tester.hosts.first}" do
      'pwd'
    end
    # @tester.announce_test_results
    @tester.clear_failure_stats
    assert tmp, "should be able to run on #{@tester.hosts.first} as root"
  end

  def test_deploy_test_in_ssh_session
    @tester.deploy_test_in_ssh_session @tester.hosts.first, "/home/#{@tester.host_admin}", "can't run as #{@tester.host_admin} on host" do
      'pwd'
    end
  end

  def test_deploy_test_on_all_hosts_as
    @tester.deploy_test_on_all_hosts_as 'root', '/root', "can't run as root on all hosts" do
      'pwd'
    end
  end

  def test_deploy_test_on_all_hosts
    @tester.deploy_test_on_all_hosts "/home/#{@tester.host_admin}", 'can\'t run on some hosts' do
      'pwd'
    end
  end
end
