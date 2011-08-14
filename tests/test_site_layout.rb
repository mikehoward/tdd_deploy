$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/site_tests/site_layout'

class TestSiteLayoutTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::SiteLayout.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch'
    @tester.clear_failure_stats
  end

  def teardown
    @tester = nil
  end

  def test_site_home
    assert @tester.test_site_subdir, "Directory /home/#{@tester.site_user}/#{@tester.site} should exist"
  end
  
  def test_site_releases
    assert @tester.test_releases_subdir, "Directory /home/#{@tester.site_user}/#{@tester.site}/releases should exist"
  end
  
  def test_site_nginx_conf
    assert @tester.test_nginx_conf, "Directory /home/#{@tester.site_user}/nginx_conf should exist"
  end
  
  def test_site_monitrc
    assert @tester.test_monitrc, "Directory /home/#{@tester.site_user}/monitrc should exist"
  end
end


