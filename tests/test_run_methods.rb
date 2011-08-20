$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'

class RunMethodsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  include TddDeploy::RunMethods

  def setup
    self.reset_env
    self.set_env :hosts => 'arch,ubuntu', :host_admin => 'mike', :ssh_timeout => 2
  end

  # def test_run_in_ssh_session_as
  #   stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch', 'pwd'
  #   assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
  #   assert_nil stderr, "should not return error if can connect to host"
  #   assert_equal 'pwd', cmd, 'cmd should be pwd'
  #     
  #   stdout, stderr = run_in_ssh_session_as 'mike', 'no-host', 'pwd'
  #   refute_equal "/home/mike\n", stdout, "should not return home directory for bad host name"
  #   refute_nil stderr, "should return an error message for bad host name"
  #   assert_equal 'pwd', cmd, 'cmd should be pwd'
  #     
  #   stdout, stderr = run_in_ssh_session_as 'no-user', 'arch', 'pwd'
  #   refute_equal "/home/mike\n", stdout, "should not return home directory for bad user name"
  #   refute_nil stderr, "should return an error message for bad user name"
  # end
  # 
  # def test_run_in_ssh_session_as
  #   stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch' do
  #     'pwd'
  #   end
  #   assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
  #   assert_nil stderr, "should not return error if can connect to host"
  #   assert_equal 'pwd', cmd, 'cmd should be pwd'
  # end
  # 
  # def test_run_in_ssh_session
  #   stdout, stderr, cmd = run_in_ssh_session('arch') { 'pwd' }
  #   assert_equal "/home/mike\n", stdout, "should be able to run as mike on host arch"
  #   assert_nil stderr, "should not return error if can connect to host"
  #   assert_equal 'pwd', cmd, 'cmd should be pwd'
  # end
  # 
  # def test_run_on_all_hosts_as
  #   results = run_on_all_hosts_as('root') { 'pwd'}
  #   refute_nil results, "results should not be nil"
  #   assert results.is_a?(Hash), "results should be a Hash"
  #   assert_equal 2, results.size, "results should have two entries"
  #   
  #   assert_equal "/root\n", results['arch'][0], "should run correctly on arch"
  #   assert_nil results['arch'][1], "no errors on arch"
  #   assert_equal results['arch'][2], 'pwd', 'cmd should be pwd'
  #   
  #   assert_nil results['ubuntu'][0], "no stdout for ubuntu"
  #   refute_nil results['ubuntu'][1], 'failure message for ubuntu'
  #   assert_equal results['ubuntu'][2], 'pwd', 'cmd should be pwd'
  # end
  # 
  # def test_run_on_all_hosts
  #   results = run_on_all_hosts { 'pwd' }
  # 
  #   assert_equal "/home/mike\n", results['arch'][0], "should run correctly on arch"
  #   assert_nil results['arch'][1], "no errors on arch"
  #   assert_equal results['arch'][2], 'pwd', 'cmd should be pwd'
  #   
  #   assert_nil results['ubuntu'][0], "no stdout for ubuntu"
  #   refute_nil results['ubuntu'][1], 'failure message for ubuntu'
  #   assert_equal results['ubuntu'][2], 'pwd', 'cmd should be pwd'
  # end
  # 
  # def test_run_locally
  #   stdout, stderr, cmd = run_locally { 'echo foo' }
  #   assert_equal "foo\n", stdout, "echo foo should echo foo\\n"
  #   assert_nil stderr, "stderr should be nil"
  #   assert_equal 'echo foo', cmd, "cmd should be 'echo foo'"
  # 
  #   stdout, stderr, cmd = run_locally { 'bad-command foo' }
  #   assert_nil stdout, "stdout should be nil for bad command"
  #   refute_nil stderr, "stderr should not be nil"
  #   assert_equal 'bad-command foo', cmd, "cmd should be 'bad-command foo'"
  # end
  # 
  # def test_run_locally_with_input
  #   input_text = "one line of text\n"
  #   stdout, stderr, cmd = run_locally(input_text) { 'cat -' }
  #   assert_equal input_text, stdout, "command should echo input: '#{input_text}"
  #   assert_nil stderr, "command should not generate errs"
  # end
  
  def test_copy_file_to_remote_as
    require 'tempfile'
    tmp_file = Tempfile.new('foo')
    input_text = "line one\nline two\nline 3\n"
    tmp_file.write input_text
    tmp_file.close
    result = copy_file_to_remote_as 'mike', 'arch', tmp_file.path, 'foo'
puts "result: #{result.inspect}"
    
    stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch', 'cat foo'
    assert_equal input_text, stdout, "remote file should contain input_text"

    assert result, "copy should return true"
  end
  
  # def test_copy_file_to_remote
  #   File.new()"line one\nline two\nline 3\n"
  #   stdout, stdin, cmd = copy_file_to_remote 'arch', 'test-file' do
  #     input_text
  #   end
  #   assert_equal stdout, '', "stdout should be empty"
  #   assert_equal stderr, '', "stderr should be empty"
  #   assert_equal 'cat - >test-file', cmd, "cmd should be 'cat - >test-file'"
  #   
  #   stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch', 'cat test-file'
  #   assert_equal input_text, stdout, "remote file should contain input_text"
  # end
end