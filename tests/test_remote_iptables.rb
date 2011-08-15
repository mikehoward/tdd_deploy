$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/remote_iptables'

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
    assert @tester.tcp_some_blocked_ports
  end

  def test_udp_some_blocked_ports
    assert @tester.udp_some_blocked_ports
  end
end
