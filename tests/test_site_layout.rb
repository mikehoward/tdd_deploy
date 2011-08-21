$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/site_tests/site_layout'

class TestSiteLayoutTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::SiteLayout.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch'
    @tester.reset_tests
  end

  def teardown
    @tester = nil
  end

  def test_site_home
    assert @tester.test_site_subdir, "Directory /home/#{@tester.site_user}/#{@tester.site}.d should exist"
  end
  
  def test_site_releases
    assert @tester.test_releases_subdir, "Directory /home/#{@tester.site_user}/#{@tester.site}.d/releases should exist"
  end
  
  def test_site_configuration_dir_exists
    assert @tester.test_site_dir_exists, @tester.formatted_test_results
  end

  def test_site_nginx_conf
    assert @tester.test_nginx_conf, "Directory /home/#{@tester.site_user}/site/nginx_conf should exist"
  end
  
  def test_site_monitrc
    assert @tester.test_monitrc, "Directory /home/#{@tester.site_user}/site/monitrc should exist"
  end
  
  def test_test_thin_conf
    assert @tester.test_thin_conf, @tester.formatted_test_results
  end

  def test_test_one_thin_server_conf
    assert @tester.test_one_thin_server_conf, @tester.formatted_test_results
  end

  def test_test_one_thin_server
    assert @tester.test_one_thin_server, @tester.formatted_test_results
  end
  
end
