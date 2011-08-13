$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/host_tests/remote_postgresql'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class  RemotePostgresqlTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::RemotePostgresql.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end
  
  def teardown
    @tester = nil
  end

  def test_postgresql_installed
    assert @tester.test_postgresql_installed, "postgresql is installed"
  end

  def test_postgreql_running
    assert @tester.test_postgresql_running, "postgresql is running"
  end
end
