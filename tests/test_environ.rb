$:.unshift File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy/environ'

class TestEnvironTestCase < Test::Unit::TestCase
  include TddDeploy::Environ

  def setup
    self.class.reset_env
  end

  def test_class_variable_assessors
    [:env_hash, :env_types, :env_defaults].each do |sym|
      assert self.class.respond_to?(sym), "#{self.class} responds to #{sym}"
    end
  end
  
  def test_env_type
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |sym|
      assert self.class.env_types.keys.include?(sym.to_s), "#{self.class}#env_types.keys includes #{sym}"
    end
    ["ssh_timeout", "site_base_port", "site_num_servers"].each do |key|
      assert_equal :int, self.class.env_types[key], "#{self.class}#env_types[#{key}] should be :int"
    end
    ["host_admin", "local_admin", "local_admin_email", "site", "site_user"].each do |key|
      assert_equal :string, self.class.env_types[key], "#{self.class}#env_types[#{key}] should be :string"
    end
    ["balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_equal :list, self.class.env_types[key], "#{self.class}#env_types[#{key}] should be :list"
    end
  end
  
  def test_hosts_pseudokey
    self.set_env :web_hosts => '', :db_hosts => ''
    assert_equal [], self.web_hosts, "assigning '' to web_hosts should create empty list"
    assert_equal [], self.db_hosts, "assigning '' to db_hosts should create empty list"
    self.set_env :hosts => 'foo,bar'
    assert_equal ['bar', 'foo'], self.hosts, "assigning foo,bar to hosts should create ['bar', 'foo']"
  end
  
  def test_env_hash
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_not_nil self.class.env_hash[key], "self.class.env_hash[#{key}] should not be nil"
    end
  end
  
  def test_env_defaults
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_not_nil self.class.env_defaults[key], "self.class.env_defaults[#{key}] should not be nil"
    end
  end
  
  def test_instance_access_to_env_hash
    assert_equal self.class.env_hash, self.env_hash, "self.env_hash == self.class.env_hash"
    assert self.env_hash.is_a?(Hash), "self.env_hash is a Hash"
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user"].each do |key|    
      assert_equal self.class.env_defaults[key], self.env_hash[key], "self.env_hash[#{key}] has proper value"
    end
    ["balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert self.env_hash[key].is_a?(Array), "self.env_hash[#{key}] is an Array"
      assert_equal self.class.env_defaults[key], self.env_hash[key].join(','), "self.env_hash[#{key}] matches default"
    end
  end
  
  def test_instance_assignment_accessors
    assert_equal self.class.env_hash['ssh_timeout'], self.ssh_timeout, "self.ssh_timeout == self.class.env_hash['ssh_timeout']"
    ssh_timeout = self.ssh_timeout
    self.ssh_timeout += 12
    assert_equal (ssh_timeout + 12), self.ssh_timeout, "self.ssh_timeout == #{ssh_timeout + 12}"
    ["ssh_timeout", "site_base_port", "site_num_servers"].each do |key|
      tmp = self.send(key.to_sym) + 12
      self.send "#{key}=", tmp
      assert_equal tmp, self.send(key.to_sym), "#{self.class}##{key} should now be #{tmp}"
    end
    ["host_admin", "local_admin", "local_admin_email", "site", "site_user"].each do |key|
      tmp = "#{key}-changed"
      self.send "#{key}=", tmp
      assert_equal tmp, self.send(key.to_sym), "#{self.class}##{key} should now be #{tmp}"
    end
    ["balance_hosts", "db_hosts", "web_hosts"].each do |key|
      tmp = self.send(key.to_sym).join(',') + ',new,values'
      self.send "#{key}=", tmp
      assert_equal tmp.split(/,/), self.send(key.to_sym), "#{self.class}##{key} should now be #{tmp}"
    end
  end
  
  def test_class_level_reset_env
    tmp = self.class.env_hash['ssh_timeout']
    self.class.set_env 'ssh_timeout' => 12
    assert_equal 12, self.class.env_hash['ssh_timeout'], "reset_env should change env_hash"
    assert_equal 12, self.ssh_timeout, "reset_env change should show up in instance method"
  end
  
  def test_instance_level_reset_env
    tmp = self.class.env_hash['ssh_timeout']
    self.set_env 'ssh_timeout' => 12
    assert_equal 12, self.class.env_hash['ssh_timeout'], "reset_env should change env_hash"
    assert_equal 12, self.ssh_timeout, "reset_env change should show up in instance method"
  end
  
  def test_instance_env_hash_assign
    assert_raises(ArgumentError) { self.env_hash = 'a string' }
    assert_raises(ArgumentError) {self.env_hash = {'foo' => 'bar'}}
  end
  
  def test_save_env
    self.save_env
  end
end
