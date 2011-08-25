$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/copy_methods'

class RunMethodsTestCase < Test::Unit::TestCase
  include TddDeploy::Environ
  include TddDeploy::RunMethods
  include TddDeploy::CopyMethods

  def setup
    self.reset_env
    self.set_env :hosts => 'arch,ubuntu', :host_admin => 'mike', :ssh_timeout => 2
    run_on_hosts_as 'site_user', 'arch', 'rm -f test-file'
    run_on_hosts_as 'site_user', 'arch', 'rmdir test-dir'
  end

  def teardown
    run_on_hosts_as 'site_user', 'arch', 'rm -f test-file'
    run_on_hosts_as 'site_user', 'arch', 'rmdir test-dir'
  end
  
  def test_mkdir_on_remote_as
    result = mkdir_on_remote_as 'site_user', 'arch', 'test-dir'
    assert result, "mkdir_on_remote_as site_user on arch returns true"
    stdout, stderr, cmd = run_in_ssh_session_on_host_as 'site_user', 'arch', 'test -d test-dir && echo "success"'
    assert_equal "success\n", stdout, "deploy_test_file_exists_on_hosts_as says 'test-dir' exists"
    
    stdout, stderr, cmd = run_in_ssh_session_on_host_as 'site_user', 'arch', 'rmdir test-dir ; test -d test-dir || echo "success"'
    assert_equal "success\n", stdout, "deploy_test_file_exists_on_hosts_as says 'test-dir' removed"
  end

  def test_copy_string_to_remote_file_as
    str = "line 1\nline 2\nline 3\n"
    result = copy_string_to_remote_file_as 'site_user', 'arch', str, 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"
    
    stdout, stderr, cmd = run_in_ssh_session_on_host_as('site_user', 'arch', 'cat test-file')
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
      result = copy_file_to_remote_as 'site_user', 'arch', tmp_file.path, 'test-file'
    
      stdout, stderr, cmd = run_in_ssh_session_on_host_as 'site_user', 'arch', 'cat test-file'
      assert_equal input_text, stdout, "remote file should contain input_text"

      assert result, "copy should return true"
    ensure
      tmp_file.unlink
    end
  end
  
  def test_copy_string_to_remote_on_hosts_as
    host_list = ['arch']
    str = "line 1\nline 2\nline 3\n"
    result = copy_string_to_remote_file_on_hosts_as 'site_user', host_list, str, 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"
    
    result = run_on_hosts_as('site_user', host_list, 'cat test-file')
    refute_nil result, "run_on_hosts_as ran on #{host_list.inspect}"
    assert_equal str, result['arch'][0], "test-file should exist on arch"
    assert_nil result['arch'][1], "stderr should be nil"
  end
  
  
  def test_copy_string_to_remote_on_hosts_as_with_host_list_as_str
    host_list = 'arch'
    str = "line 1\nline 2\nline 3\n"
    result = copy_string_to_remote_file_on_hosts_as 'site_user', host_list, str, 'test-file'
    assert result, "copy_string_to_remote_file_as returns true on success"
    
    result = run_on_hosts_as('site_user', host_list, 'cat test-file')
    refute_nil result, "run_on_hosts_as ran on #{host_list.inspect}"
    assert_equal str, result['arch'][0], "test-file should exist on arch"
    assert_nil result['arch'][1], "stderr should be nil"
  end
  
  
  def test_copy_file_to_remote_on_hosts_as
    host_list = ['arch']
    require 'tempfile'
    tmp_file = Tempfile.new('foo')
    begin
      input_text = "line one\nline two\nline 3\n"
      tmp_file.write input_text
      tmp_file.close
      result = copy_file_to_remote_on_hosts_as 'site_user', host_list, tmp_file.path, 'test-file'
    
      results = run_on_hosts_as 'site_user', host_list, 'cat test-file'
      assert_equal input_text, results['arch'][0], "remote file should contain input_text"

      assert result, "copy should return true"
    ensure
      tmp_file.unlink
    end
  end

  def test_copy_dir_to_remote_on_hosts_as
    host_list = ['arch']
    dir_name = 'test_copy_dir_to_remote_on_hosts_as'
    Dir.mkdir dir_name unless File.exists? dir_name
    ['foo', 'bar', 'baz'].each do |fname|
      path = File.join(dir_name, fname)
      f = File.new(path, 'w')
      f.write "This is a file named #{fname}\n"
      f.close
    end
    
    assert copy_dir_to_remote_on_hosts_as('site_user', host_list, dir_name, dir_name), 'copy directory should work'

    result_hash = run_on_hosts_as 'site_user', host_list, "ls"
    assert_match /test_copy_dir_to_remote_on_hosts_as/, result_hash['arch'][0], "ls of home should contain directory name"

    result_hash = run_on_hosts_as 'site_user', host_list, "ls #{dir_name}"
    listing = result_hash['arch'][0].split(/\n/)
    ['foo', 'bar', 'baz'].each do |fname|
      assert listing.include?(fname), "listing of remote directory contains '#{fname}'"
    end
    ['foo', 'bar', 'baz'].each do |fname|
      path = File.join dir_name, fname
      stdout, stderr, cmd = run_in_ssh_session_on_host_as 'site_user', 'arch', "cat #{path}"
      assert_equal "This is a file named #{fname}\n", stdout, "copy_dir... should copy file contents of #{fname}"
    end
  end

end