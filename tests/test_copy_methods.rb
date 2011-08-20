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
    str = "line 1\nline 2\nline 3\n"
    result = copy_string_to_remote_file_as 'site_user', 'arch', str, 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"
    
    stdout, stderr, cmd = run_in_ssh_session_as('site_user', 'arch', 'cat test-file')
    assert_equal str, stdout, "test-file should exist on arch"
    assert_nil stderr, "stderr should be nil"
  end

 
  def test_copy_string_to_remote_file
    str = "line 1\nline 2\nline 3\n"
    result = copy_string_to_remote_file 'arch', str, 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"

    stdout, stderr, cmd = run_in_ssh_session 'arch', 'cat test-file'
    assert_equal str, stdout, "test-file should exist on arch"
    assert_nil stderr, "stderr should be nil"
  end

  def test_copy_file_to_remote_as
    require 'tempfile'
    tmp_file = Tempfile.new('foo')
    begin
      input_text = "line one\nline two\nline 3\n"
      tmp_file.write input_text
      tmp_file.close
      result = copy_file_to_remote_as 'site_user', 'arch', tmp_file.path, 'foo'
    
      stdout, stderr, cmd = run_in_ssh_session_as 'site_user', 'arch', 'cat foo'
      assert_equal input_text, stdout, "remote file should contain input_text"

      assert result, "copy should return true"
    ensure
      tmp_file.unlink
      run_in_ssh_session_as 'site_user', 'arch', 'rm -f foo'
    end
  end
  
  def test_copy_file_to_remote
    require 'tempfile'
    tmp_file = Tempfile.new('foo')
    begin
      input_text = "line one\nline two\nline 3\n"
      tmp_file.write input_text
      tmp_file.close
      result = copy_file_to_remote 'arch', tmp_file.path, 'foo'
    
      stdout, stderr, cmd = run_in_ssh_session_as 'mike', 'arch', 'cat foo'
      assert_equal input_text, stdout, "remote file should contain input_text"

      assert result, "copy should return true"
    ensure
      tmp_file.unlink
      run_in_ssh_session_as 'mike', 'arch', 'rm -f foo'
    end
  end
end