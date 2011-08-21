$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'

class TddDeployContextHelper
  include TddDeploy::Environ
end

class TestTddDeployContextTestCase < Test::Unit::TestCase
  GEM_ROOT = File.expand_path('../..', __FILE__)
  BIN_DIR = File.join(GEM_ROOT, 'bin')

  include TddDeploy::RunMethods

  def setup
    @helper = TddDeployContextHelper.new
    @helper.reset_env
    @helper.save_env
  end

  def teardown
    @helper.reset_env
    @helper.save_env
    @helper = nil
  end

  def test_set_env_rb_exists
    assert File.exists?(File.join(BIN_DIR, 'tdd_deploy_context')), "tdd_deploy_context exists"
  end
  
  def test_run_context_editor
    stdout, stderr, cmd = run_locally 'quit' do
      "#{File.join(BIN_DIR, 'tdd_deploy_context')}"
    end
    assert_not_nil stdout, "tdd_deploy_context is runable. stderr: #{stderr}"
    assert_nil stderr, "tdd_deploy_context does not generate errors"
  end
  
  def test_changing_env
    command = "web_hosts frog toad turtle\nssh_timeout 12\nsave\n"
    stdout, stderr, cmd = run_locally command do
      "#{File.join(BIN_DIR, 'tdd_deploy_context')}"
    end
    assert_not_nil stdout, "successful run should not be nil: stderr: #{stderr}"
    assert_match /"frog"/, stdout, "'frog' should be in stdout"
    assert_match /abort/i, stderr, "tdd_deploy_context generates abort error"
    refute_match /discard/i, stderr, "tdd_deploy_context should not discard edits"
  end
end
