$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/remote_monit'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  RemoteMonitTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::RemoteMonit.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end
  
  def teardown
    @tester = nil
  end

  def test_monit_installed
    assert @tester.test_monit_installed, "monit is installed"
  end

  def test_monit_running
    assert @tester.test_monit_running, "monit is running"
  end
end
