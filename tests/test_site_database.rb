$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/site_tests/site_database'

class TestSiteDatabaseTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::SiteDatabase.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :host_admin => 'mike', :local_admin => 'mike'
  end

  def teardown
    @tester = nil
  end

  def test_site_database_test
    assert @tester.test_site_db_defined, "Site database #{@tester.site} defined"
  end
end


