$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/remote_ip_tables'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  RemoteIptablesTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::RemoteIpTables.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end

  def teardown
    @tester = nil
  end

  def test_tcp_some_blocked_ports
    @tester.tcp_some_blocked_ports
    @tester.hosts.each do |host|
      assert_equal 0, @tester.failure_count(host), "all tested ports blocked for host #{host}"
    end
  end
  
  def test_tcp_some_blocked_ports_non_responsive_host
    host = 'no-host'
    @tester.set_env :hosts => host
    @tester.tcp_some_blocked_ports
    assert_equal 1, @tester.failure_count(host), "cannot test iptables on non-responding host"
  end
end
