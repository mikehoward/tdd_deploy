$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/remote_postfix'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  RemotePostfixTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::RemotePostfix.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end
  
  def teardown
    @tester = nil
  end

  def test_postfix_installed
    assert @tester.test_postfix_installed, "postfix is installed"
  end

  def test_postfix_running
    assert @tester.test_postfix_running, "postfix is running"
  end
end
