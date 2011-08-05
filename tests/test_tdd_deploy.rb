$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy'

class TestTddDeployTestCase < Test::Unit::TestCase
  include TddDeploy

  def setup
    # File.delete TddDeploy::ENV_FNAME if File.exists? TddDeploy::ENV_FNAME
  end
  
  def teardown
    env_defaults = {
      'ssh_timeout' => 5,
      'host_admin' => "'host_admin'",
      'hosts' => "''",
      'local_admin' => "'local_admin'",
      'local_admin_email' => "'local_admin@bogus.tld'",
  
      'site' => "'site'",
      'site_user' => "'site_user'",
      'site_base_port' => 8000,
      'site_num_servers' => 3,
    }
    self.class.read_env env_defaults
    self.class.save_env
  end

  def test_responds_to_class_methods
    [:env_hash, :read_env, :save_env].each do |func|
      assert self.class.respond_to?(func), "#{self.class} should respond to #{func}"
    end
  end
  
  def test_responds_to_instance_methods
    [:save_env].each do |func|
      assert self.respond_to?(func), "#{self} should respond to #{func}"
    end
  end
  
  def test_env_hash
    assert self.class.env_hash.is_a?(Hash), "#{self.class}.env_hash should be a Hash"
  end
  
  def test_env_defaults
    env_defaults = {
      'ssh_timeout' => 5,
      'host_admin' => "'host_admin'",
      'hosts' => "''",
      'local_admin' => "'local_admin'",
      'local_admin_email' => "'local_admin@bogus.tld'",
  
      'site' => "'site'",
      'site_user' => "'site_user'",
      'site_base_port' => 8000,
      'site_num_servers' => 3,
    }
    self.class.read_env env_defaults
    env_defaults.each do |k, v|
      assert_equal v, self.send(k.to_sym), "self.#{k} should be #{v}"
      assert_equal v, self.class.env_hash[k], "the default env should set :#{k} to '#{v}'"
    end
  end
  
  def test_changing_env
    self.ssh_timeout = 10
    assert_equal 10, self.ssh_timeout, "ssh_timeout should now be 10"
    assert_equal 10, self.class.env_hash['ssh_timeout'], "env_hash['ssh_timeout'] should be 10"

    self.class.save_env
    env_hash_save = self.class.env_hash.clone
    self.class.read_env
    assert_equal env_hash_save, self.class.env_hash, "save and reload env_hash should be idempotent"

    assert_equal 10, self.ssh_timeout, "ssh_timeout should still be 10"
    assert_equal 10, self.class.env_hash['ssh_timeout'], "env_hash['ssh_timeout'] should still be 10"
   end
end
