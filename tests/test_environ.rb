$:.unshift File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'test_helpers'
require 'tdd_deploy/environ'

class Base
  include TddDeploy::Environ
end

class Foo < Base
end

class Bar < Base
end

class TestEnvironTestCase < Test::Unit::TestCase
  include TddDeploy::Environ

  def setup
    @foo = Foo.new@foo
    @foo.reset_env
  end
  
  def teardown
    @foo.reset_env
    @foo.save_env
  end

  def test_class_variable_assessors
    [:env_hash, :env_types, :env_defaults].each do |sym|
      assert @foo.respond_to?(sym), "#{@foo.class} responds to #{sym}"
    end
  end
  
  def test_env_type
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |sym|
      assert @foo.env_types.keys.include?(sym.to_s), "#{@foo.class}#env_types.keys includes #{sym}"
    end
    ["ssh_timeout", "site_base_port", "site_num_servers"].each do |key|
      assert_equal :int, @foo.env_types[key], "#{@foo.class}#env_types[#{key}] should be :int"
    end
    ["host_admin", "local_admin", "local_admin_email", "site", "site_user"].each do |key|
      assert_equal :string, @foo.env_types[key], "#{@foo.class}#env_types[#{key}] should be :string"
    end
    ["balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_equal :list, @foo.env_types[key], "#{@foo.class}#env_types[#{key}] should be :list"
    end
  end
  
  def test_hosts_pseudokey
    @foo.set_env :web_hosts => '', :db_hosts => ''
    assert_equal [], @foo.web_hosts, "assigning '' to web_hosts should create empty list"
    assert_equal [], @foo.db_hosts, "assigning '' to db_hosts should create empty list"
    @foo.set_env :hosts => 'foo,bar'
    assert_equal ['bar', 'foo'], @foo.hosts, "assigning foo,bar to hosts should create ['bar', 'foo']"
  end
  
  def test_env_hash
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_not_nil @foo.env_hash[key], "@foo.env_hash[#{key}] should not be nil"
    end
  end
  
  def test_env_defaults
    ["ssh_timeout", "site_base_port", "site_num_servers", "host_admin", "local_admin", "local_admin_email",
    "site", "site_user", "balance_hosts", "db_hosts", "web_hosts"].each do |key|
      assert_not_nil @foo.env_defaults[key], "@foo.env_defaults[#{key}] should not be nil"
    end
  end

  def test_instance_assignment_accessors
    assert_equal @foo.env_hash['ssh_timeout'], @foo.ssh_timeout, "@foo.ssh_timeout == @foo.env_hash['ssh_timeout']"
    ssh_timeout = @foo.ssh_timeout
    @foo.ssh_timeout += 12
    assert_equal(ssh_timeout + 12, @foo.ssh_timeout, "@foo.ssh_timeout == #{ssh_timeout + 12}")
    ["ssh_timeout", "site_base_port", "site_num_servers"].each do |key|
      tmp = @foo.send(key.to_sym) + 12
      @foo.send "#{key}=", tmp
      assert_equal tmp, @foo.send(key.to_sym), "#{@foo.class}##{key} should now be #{tmp}"
    end
    ["host_admin", "local_admin", "local_admin_email", "site", "site_user"].each do |key|
      tmp = "#{key}-changed"
      @foo.send "#{key}=", tmp
      assert_equal tmp, @foo.send(key.to_sym), "#{@foo.class}##{key} should now be #{tmp}"
    end
    ["balance_hosts", "db_hosts", "web_hosts"].each do |key|
      tmp = @foo.send(key.to_sym).join(',') + ',new,values'
      @foo.send "#{key}=", tmp
      assert_equal tmp.split(/,/), @foo.send(key.to_sym), "#{@foo.class}##{key} should now be #{tmp}"
    end
  end
  
  def test_instance_level_reset_env
    tmp = @foo.env_hash['ssh_timeout']
    @foo.set_env 'ssh_timeout' => 12
    assert_equal 12, @foo.env_hash['ssh_timeout'], "reset_env should change env_hash"
    assert_equal 12, @foo.ssh_timeout, "reset_env change should show up in instance method"
  end
  
  def test_instance_env_hash_assign
    assert_raises(ArgumentError) { @foo.env_hash = 'a string' }
    assert_raises(ArgumentError) {@foo.env_hash = {'foo' => 'bar'}}
  end
  
  def test_save_env
    zap_hash = Hash[ @foo.env_types.keys.map { |k| [k, nil] } ]
    @foo.env_hash = zap_hash
    @foo.save_env
    @foo.read_env
    @foo.env_hash.each do |k, v|
      case @foo.env_types[k]
      when :int then expect = 0
      when :string then expect = ''
      when :list then expect = []
      end
      assert_equal expect, @foo.env_hash[k], "After Zapping, env_hash['#{k}'] should be #{expect}"
      assert_equal expect, @foo.send(k.to_sym), "After Zapping, @foo.#{k} should be #{expect}"
    end
  end

  def test_transfer_env
    @foo.ssh_timeout = 401
    bar = Bar.new
    assert_equal 401, bar.ssh_timeout, "Setting env in one object should transfer to another"
  end
end
