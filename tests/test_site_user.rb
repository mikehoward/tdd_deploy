$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/site_tests/site_user'

class TestSiteUserTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::SiteUser.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end

  def teardown
    @tester = nil
  end

  def test_login_as_site_user
    assert @tester.test_login_as_site_user, "Unable to login to some hosts as #{@tester.site_user}"
  end
end


