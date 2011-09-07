$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/server'
require 'tdd_deploy/test_base'

class TestServerTestCase < Test::Unit::TestCase
  GEM_ROOT = File.expand_path('../..', __FILE__)
  BIN_DIR = File.join(GEM_ROOT, 'bin')

  include TddDeploy::Environ

  def setup
    # we can't create a server w/o an environment, but we flush it between tests.
    # so we have to create the enviornment file here
    self.reset_env
    self.save_env

    @tester = TddDeploy::Server.new
    @tester.set_env(:web_hosts => 'arch', :db_hosts => 'arch', 
      :host_admin => 'mike', :local_admin => 'mike', :ssh_timeout => 2,
      :site => 'site', :site_user => 'site_user', :site_special_dir => 'non-special-special-dir')
    @tester.save_env
    @tester.run_on_a_host_as 'site_user', 'arch', "mkdir #{@tester.site_special_dir}"
    ['monitrc', 'one_thin_server', 'nginx.conf'].each do |fname|
      @tester.run_on_a_host_as 'site_user', 'arch', "echo '# #{fname}' >#{@tester.site_special_dir}/#{fname}"
    end
  end
  
  def teardown
    system('rm -f site_host_setup.env')
    TddDeploy::TestBase.flush_children_methods
    @tester.load_all_tests
    @tester.run_on_a_host_as 'site_user', 'arch', "rm #{@tester.site_special_dir}/*"
    @tester.run_on_a_host_as 'site_user', 'arch', "rmdir #{@tester.site_special_dir}"
    @tester = nil
  end
  
  def test_env_file_detection
    File.unlink TddDeploy::Environ::ENV_FNAME
    assert_raises RuntimeError do
      TddDeploy::Server.new
    end
  end
  
  def test_classes_array
    @tester.load_all_tests
    assert_not_nil @tester.test_classes, "@tester.test_classes should not be nil"
    assert @tester.test_classes.include?(TddDeploy::HostConnection), "@tester.test_classes should contain TddDeploy::HostConnection"
  end
  
  def test_run_all_tests
    ret = @tester.run_all_tests
    failures = "\n" + (@tester.failure_messages('arch') || []).join("\n") + "\n"
    assert ret, "@tester should run all tests and return true: returned: #{ret.inspect}: #{failures}"
    # puts @tester.formatted_test_results
  end

  def test_run_a_test
    assert @tester.send(:run_a_test, 'return_true'), "return_true should pass"
  end
  
  def test_run_some_tests
    assert @tester.send(:run_selected_tests, 'return_true,smoke'), 'run_selected_tests should work with a string'
    assert @tester.send(:run_selected_tests, ['return_true', 'smoke']), 'run_selected_tests can run two tests'
  end
  
  def test_capistrano_attributes
    assert_equal ['app1', 'app2', 'app3'], @tester.app, "Capistrano app should be an array of three hosts"
  end
  
  def test_parse_query_string
    qs = @tester.send :parse_query_string, "foo=bar&bar=some%20stuff"
    assert_equal 2, qs.length, "query string should have to entries"
    assert_equal 'bar', qs['foo'], "qs['foo'] should be 'bar'"
    assert_equal 'some stuff', qs['bar'], "qs['bar'] should be 'some stuff'"
  end
  
  def test_failed_tests
    assert @tester.failed_tests.is_a?(Array), "failed_tests is an Array"
    @tester.failed_tests = :foo
    assert_equal ['foo'], @tester.failed_tests, "can assign symbol to failed_tests"
    @tester.failed_tests = 'foo'
    assert_equal ['foo'], @tester.failed_tests, "can assign String to failed_tests"
    @tester.failed_tests = ['foo', 'bar']
    assert_equal ['bar','foo'], @tester.failed_tests, "can assign Array of Strings to failed_tests"
    @tester.failed_tests = ['foo', :bar]
    assert_equal ['bar', 'foo'], @tester.failed_tests, "can assign Array of Strings and symbols to failed_tests"
    @tester.failed_tests.push('baz')
    assert_equal ['bar', 'baz', 'foo'], @tester.failed_tests, "pushing string should work"
    @tester.failed_tests.push(:snort)
    assert_equal ['bar', 'baz', 'foo', 'snort'], @tester.failed_tests, "pushing symbol should work"
    @tester.failed_tests.push('foo')
    assert_equal ['bar', 'baz', 'foo', 'snort'], @tester.failed_tests, "pushing duplicate should not add entry"
  end

  def test_new_query_string
    @tester.failed_tests = [:foo, :bar, :baz]
    assert_equal 'failed-tests=bar,baz,foo', @tester.send(:new_query_string), "new query string should be correct"
  end
  
  def test_render_results
    assert_match /Test Results/, @tester.send(:render_results), "render results should return a page"
  end

  def test_rack_interface
    code, headers, body = @tester.call({})
    assert_equal 200, code, "@tester always responds with 200"
    assert_not_nil body, "body should not be nil"
    assert_equal 'text/html', headers['Content-Type'], "Content-Type is text/html"
    assert_equal headers['Content-Length'].to_i, body.join('').length, "Content-Length is the size of body"
  end
end
