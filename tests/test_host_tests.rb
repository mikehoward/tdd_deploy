$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'
require 'tdd_deploy/host_tests/host_connection'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  HostTestsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  # include TddDeploy::HostConnection

  def setup
    self.reset_env
    self.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
    @host_tester = TddDeploy::HostConnection.new
  end

  def test_ping
puts "@host_tester: #{@host_tester}"
ping_method = @host_tester.method :ping
puts "arity of ping: #{ping_method.arity}"
    @host_tester.ping
  end
  
  def test_ssh_login
    @host_tester.ssh_login
  end
end
