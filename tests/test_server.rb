$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/run_methods'

class TestServerTestCase < Test::Unit::TestCase
  GEM_ROOT = File.expand_path('../..', __FILE__)
  BIN_DIR = File.join(GEM_ROOT, 'bin')

  include TddDeploy::RunMethods
  
  def setup
    require 'tdd_deploy/server'
    @tester = TddDeploy::Server.new(:web_hosts => 'arch', :db_hosts => 'arch', 
      :host_admin => 'mike', :local_admin => 'mike', :ssh_timeout => 2,
      :site => 'site', :site_user => 'site_user')
  end
  
  def teardown
    @tester = nil
  end
  
  def test_classes_array
    @tester.load_all_tests
    assert_not_nil @tester.test_classes, "@tester.test_classes should not be nil"
    assert @tester.test_classes.include?(TddDeploy::HostConnection), "@tester.test_classes should contain TddDeploy::HostConnection"
  end
  
  def test_run_all_tests
    ret = @tester.run_all_tests
    failure_messages = "\n" + (@tester.failure_messages['arch'] || []).join("\n") + "\n"
    assert ret, "@tester should run all tests and return true: returned: #{ret.inspect}: #{failure_messages}"
    # puts @tester.test_results
  end
  
  def test_rack_interface
    code, headers, body = @tester.call({})
    assert_equal 200, code, "@tester always responds with 200"
    assert_not_nil body, "body should not be nil"
    assert_equal 'text/html', headers['Content-Type'], "Content-Type is text/html"
    assert_equal headers['Content-Length'].to_i, body.join('').length, "Content-Length is the size of body"
  end
end
