$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class DeployTester
  include TddDeploy::Environ
  include TddDeploy::RunMethods
  include TddDeploy::DeployTestMethods
  
  def initialize env_hash
    self.reset_env
    self.set_env env_hash
  end
end

class  DeployTestMethodsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ

  def setup
    self.reset_env
    self.set_env({ :host_admin => 'mike', :local_admin => 'mike', :db_hosts => 'arch', 
        :web_hosts => 'arch', :ssh_timeout => 2 })
    @tester = DeployTester.new self.env_hash
  end

  def test_default_env
    self.reset_env
    assert_equal 'host_admin', self.host_admin, "host_admin should be 'host_admin'"
    assert_equal 'local_admin', self.local_admin, "local_admin should be 'local_admin'"
    assert_equal 'local_admin@bogus.tld', self.local_admin_email, "local_admin_email should be 'local_admin@bogus.tld'"
#    assert_equal 'hosts', self.hosts, "hosts should be 'arch'"
    assert_equal ['bar', 'foo'], self.hosts, "hosts should be 'bar,foo'"
  end

  def test_custom_env
    self.set_env 'host_admin' => 'mike', :local_admin => 'mike', :local_admin_email => 'mike@clove.com'
    assert_equal 'mike', self.host_admin, "host_admin should be 'mike'"
    assert_equal 'mike', self.local_admin, "local_admin should be 'mike'"
    assert_equal 'mike@clove.com', self.local_admin_email, "local_admin_email should be 'mike@clove.com'"
    assert_equal ['arch'], self.hosts, "hosts should be 'arch'"
  end
  
  def test_force_failure
    result = @tester.deploy_test_in_ssh_session_as 'no-user', self.hosts.first, '/home/no-user', 'should fail with bad user' do
      'pwd'
    end
    refute result, "refute version: should fail with bad userid #{result}"
  end

  def test_deploy_test_in_ssh_session_as
    assert_raises ArgumentError do
      @tester.deploy_test_in_ssh_session_as 'root', self.hosts.first, '', 'session catches empty match expression' do
        'uname -a'
      end
    end

    assert_raises  do
      @tester.deploy_test_in_ssh_session_as 'root', self.hosts.first, 'no-file-exists', 'generate an error' do
        'ls /usr/no-file-exists'
      end
    end

    @tester.deploy_test_in_ssh_session_as 'root', self.hosts.first, "/root", 'can\'t run on host' do
      'pwd'
    end
  end

  def test_deploy_test_in_ssh_session
    @tester.deploy_test_in_ssh_session self.hosts.first, "/home/#{self.host_admin}", "can't run as #{self.host_admin} on host" do
      'pwd'
    end
  end

  def test_deploy_test_on_all_hosts_as
    @tester.deploy_test_on_all_hosts_as 'root', '/root', "can't run as root on all hosts" do
      'pwd'
    end
  end

  def test_deploy_test_on_all_hosts
    @tester.deploy_test_on_all_hosts "/home/#{self.host_admin}", 'can\'t run on some hosts' do
      'pwd'
    end
  end
end
