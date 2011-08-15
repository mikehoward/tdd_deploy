$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/run_methods'

class TestTddDeployServerTestCase < Test::Unit::TestCase
  GEM_ROOT = File.expand_path('../..', __FILE__)
  BIN_DIR = File.join(GEM_ROOT, 'bin')
  PORT = 8809

  include TddDeploy::RunMethods
  
  def setup
    require File.join(BIN_DIR, 'tdd_deploy_server')
    @tester = TddDeploy::Server.new(PORT, :web_hosts => 'arch', :db_hosts => 'arch', 
      :host_admin => 'mike', :local_admin => 'mike', :ssh_timeout => 2)
  end
  
  def teardown
    @tester = nil
  end

  def test_set_env_rb_exists
    assert File.exists?(File.join(BIN_DIR, 'tdd_deploy_server.rb')), "tdd_deploy_server.rb exists"
  end
  
  def test_tester_accessors
    assert_equal PORT, @tester.port, "@tester.port should be #{PORT}"
  end
  
  def test_classes_array
    @tester.load_all_tests
    assert_not_nil @tester.test_classes, "@tester.test_classes should not be nil"
    assert @tester.test_classes.include?(TddDeploy::HostConnection), "@tester.test_classes should contain TddDeploy::HostConnection"
  end
  
  def test_run_all_tests
    ret = @tester.run_all_tests
    assert ret, "@tester should run all tests and return true: #{@tester.test_failures}"
    # puts @tester.test_results
  end
  
  def test_rack_interface
    code, headers, body = @tester.call({})
    assert_equal 200, code, "@tester always responds with 200"
    assert_not_nil body, "body should not be nil"
    assert_equal 'text/html', headers['Content-Type'], "Content-Type is text/html"
    assert_equal headers['Content-Length'].to_i, body.length, "Content-Length is the size of body"
  end

  # def test_run_server
  #   stdout, stderr, cmd = run_locally 'quit' do
  #     "#{File.join(BIN_DIR, 'tdd_deploy_server')}"
  #   end
  #   assert_not_nil stdout, "tdd_deploy_server is runable. stderr: #{stderr}"
  #   assert_nil stderr, "tdd_deploy_server does not generate errors"
  # end
  
end
