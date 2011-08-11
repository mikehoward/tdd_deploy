$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy'

class TestTddDeployTestCase < Test::Unit::TestCase
  include TddDeploy
  # puts "self: #{self}"
  # puts "self.public_methods: #{self.public_methods(false).sort}"
  # puts "self.instance_methods: #{self.instance_methods.sort}"
  def setup
    self.reset_env
  end
  
  def test_exsistence_of_public_methods
    [:reset_env, :read_env, :reset_env].each do |meth|
      assert self.class.respond_to?(meth), "self.class should respond to #{meth}"
    end
  end
  def test_response_to_class_accessors
    [:env_hash, :env_defaults, :env_types].each do |meth|
      assert self.class.respond_to?("#{meth}=".to_sym), "self.class should respond to #{meth}="
      refute_nil self.class.send(meth), "self.class.#{meth} should not be nil"
    end
  end
  
  def test_resonse_to_instance_assessors
    [:env_hash, :ssh_timeout, :site_base_port, :site_num_servers,
      :host_admin, :local_admin, :local_admin_email, :site, :site_user,
      :hosts, :balance_hosts, :db_hosts, :web_hosts].each do |meth|
      assert self.respond_to?(meth), "self should respond to #{meth}"
      assert self.respond_to?("#{meth}".to_sym), "self should respond to #{meth}="
    end
  end
  
end
