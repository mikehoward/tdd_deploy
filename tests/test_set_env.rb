$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'

GEM_ROOT = File.expand_path('../..', __FILE__)
BIN_DIR = File.join(GEM_ROOT, 'bin')

class TestSetEnvTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  include TddDeploy::RunMethods

  def test_set_env_rb_exists
    assert File.exists?(File.join(BIN_DIR, 'set_env.rb')), "set_env.rb exists"
  end
  
  def test_run_env_rb
    stdout, stderr, cmd = run_locally 'quit' do
      "ruby #{File.join(BIN_DIR, 'set_env.rb')}"
    end
    assert_not_nil stdout, "std_env.rb is runable"
    assert_nil stderr, "std_env.rb does not generate errors"
  end
  
  def test_changin_env
    command = "hosts frog toad turtle\nssh_timeout 12\nsave\n"
    stdout, stderr, cmd = run_locally command do
      "ruby #{File.join(BIN_DIR, 'set_env.rb')}"
    end
    assert_match /"frog"/, stdout, command
    assert_match /abort/i, stderr, "std_env.rb generates abort error"
    refute_match /discard/i, stderr, "std_env.rb should not discard edits"
  end
end
