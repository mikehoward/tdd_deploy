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
    assert File.exists?(File.join(BIN_DIR, 'tdd_deploy_context')), "tdd_deploy_context exists"
  end
  
  def test_run_env_rb
    stdout, stderr, cmd = run_locally 'quit' do
      "ruby #{File.join(BIN_DIR, 'tdd_deploy_context')}"
    end
    assert_not_nil stdout, "tdd_deploy_context is runable"
    assert_nil stderr, "tdd_deploy_context does not generate errors"
  end
  
  def test_changin_env
    command = "hosts frog toad turtle\nssh_timeout 12\nsave\n"
    stdout, stderr, cmd = run_locally command do
      "ruby #{File.join(BIN_DIR, 'tdd_deploy_context')}"
    end
    assert_match /"frog"/, stdout, "'frog' should be instdout"
    assert_match /abort/i, stderr, "tdd_deploy_context generates abort error"
    refute_match /discard/i, stderr, "tdd_deploy_context should not discard edits"
  end
end
