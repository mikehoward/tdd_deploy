$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/installer'

class TestTddDeployInstallerTestCase < Test::Unit::TestCase
  
  def setup
    @helper = TddDeploy::Installer.new
    @helper.set_env :app_hosts => ['arch']
  end
  
  def test_install_special_files
    assert @helper.install_special_files_on_host_list_as('site_user', 'app_hosts'), "install_special_files_on_host_as should copy stuff to app_hosts"
    stdout, stderr, cmd = @helper.run_on_a_host_as 'site_user', 'arch', "ls #{@helper.site_special_dir}"
    assert_match /monitrc/, stdout, "special dir should contain monitrc"
    assert_nil stderr, "test command should run w/o errors"
  end
  
  def test_install_config_files
    assert @helper.install_config_files_on_host_list_as('site_user', 'app_hosts'), 'install config_files should return true'

    config_dir = File.join @helper.site_doc_root, '..', 'config'

    stdout, stderr, cmd = @helper.run_on_a_host_as 'site_user', 'arch', "ls #{config_dir}"
    assert_match /one_thin_server.conf/, stdout, "config dir should contain one_thin_server.conf"
    assert_nil stderr, "test command should run w/o errors"
  end
  
  def test_run_cap_deploy
    assert @helper.run_cap_deploy, "running cap deploy should succeed"
  end
end