$:.unshift File.expand_path('../../lib', __FILE__)

require 'fileutils'
require 'test/unit'
require 'tdd_deploy/configurator'

class TestTddDeployConfiguratorTestCase < Test::Unit::TestCase
  def setup
    @configurator = TddDeploy::Configurator.new
  end
  
  def teardown
    @configurator = nil
  end
  
  def test_configurator_is_an_object
    assert @configurator.is_a?(TddDeploy::Configurator), "@configurator shold be a TddDeploy::Configurator object"
  end
  
  def test_configurator_creates_files
    FileUtils.rm_rf 'tdd_deploy_configs'
    @configurator.make_configuration_files
    assert File.exists?('tdd_deploy_configs'), "tdd_deploy_configs/ exists"
    ['app_hosts', 'balance_hosts', 'db_hosts', 'web_hosts'].each do |host_dir|
      host_path = File.join('tdd_deploy_configs', host_dir)
      assert File.exists?(host_path), "#{host_path} exists"
      ['config', 'site'].each do |subdir|
        subdir_path = File.join(host_path, subdir)
        assert File.exists?(subdir_path), "#{subdir_path} exists"
        assert Dir.new(subdir_path).entries.length >= 2, "#{subdir_path} has 3 or more entries"
      end
    end
  end
end
