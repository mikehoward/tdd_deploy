$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/site_tests/site_layout'

class TestSiteLayoutTestCase < Test::Unit::TestCase
  def setup
    @tester = TddDeploy::SiteLayout.new
    @tester.reset_env
    @tester.set_env :hosts => 'arch', :site_special_dir => 'non-special-special-dir'
    @tester.reset_tests
    @tester.run_on_a_host_as 'site_user', 'arch', "mkdir #{@tester.site_special_dir}"
    ['monitrc', 'one_thin_server', 'nginx.conf'].each do |fname|
      @tester.run_on_a_host_as 'site_user', 'arch', "echo '# #{fname}' >#{@tester.site_special_dir}/#{fname}"
    end
  end

  def teardown
    @tester.run_on_a_host_as 'site_user', 'arch', "rm #{@tester.site_special_dir}/*"
    @tester.run_on_a_host_as 'site_user', 'arch', "rmdir #{@tester.site_special_dir}"
    @tester = nil
  end

  def test_site_home
    assert @tester.test_site_subdir, "Directory #{@tester.site_doc_root} should exist"
  end
  
  def test_site_releases
    assert @tester.test_releases_subdir, "Directory #{@tester.site_doc_root}/../../releases should exist"
  end
  
  def test_site_configuration_dir_exists
    assert @tester.test_site_dir_exists, @tester.formatted_test_results
  end

  def test_site_nginx_conf
    assert @tester.test_nginx_conf, "Directory #{@tester.site_special_dir}/nginx.conf should exist"
  end
  
  def test_site_monitrc
    assert @tester.test_monitrc, "Directory #{@tester.site_special_dir}/monitrc should exist"
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
