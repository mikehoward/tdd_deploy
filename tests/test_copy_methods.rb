$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/copy_methods'

class RunMethodsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  include TddDeploy::RunMethods

  def setup
    self.reset_env
    self.set_env :hosts => 'arch,ubuntu', :host_admin => 'mike', :ssh_timeout => 2
  end
  
  def test_copy_string_to_remote_file_as
    result = copy_string_to_remote_file_as 'mike', 'arch', "line 1\nline 2\nline 3\n", 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"
    
  end

#   def test_copy_file_to_remote_as
#     require 'tempfile'
#     tmp_file = Tempfile.new('foo')
#     input_text = "line one\nline two\nline 3\n"
#     tmp_file.write input_text
#     tmp_file.close
#     result = copy_file_to_remote_as 'mike', 'arch', tmp_file.path, 'foo'
# puts "test_copy_file_to_remote_as: #{__LINE__}: result: #{result.inspect}"
#     
#     stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch', 'cat foo'
#     assert_equal input_text, stdout, "remote file should contain input_text"
# 
#     assert result, "copy should return true"
#   end
  
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