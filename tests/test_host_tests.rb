$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/host_connection'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  HostTestsTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::HostConnection.new
    @tester.reset_env
    @tester.set_env :web_hosts => 'arch', :db_hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end
  
  def teardown
    @tester = nil
  end

  def test_ping
    assert @tester.ping, "Can ping #{@tester.hosts.join(',')}"
  end
  
  def test_ssh_login
    assert @tester.ssh_login, "Can login #{@tester.hosts.join(',')} as #{@tester.host_admin}"
  end
  
  def test_ssh_login_as_root
    assert @tester.ssh_login_as_root, "Can login to #{@tester.hosts.join(',')} as root"
  end
end
