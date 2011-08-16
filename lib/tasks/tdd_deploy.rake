require 'fileutils'
LIB_PATH = File.expand_path('../..', __FILE__)
LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy')

namespace :tdd_deploy do
  desc "uninstall removes gem supplied version of tests in lib/tdd_deploy/host_tests & site_tests. Doesn't touch lib/tdd_deploy/local_tests"
  task :uninstall do
    ['host_tests', 'site_tests'].each do |target_dir|
      target_path = File.join(LOCAL_TDD_DIR, target_dir)
      FileUtils.rm_r target_path if File.exists? target_path
    end
  end
  
  desc "install tdd_deploy copies tests for hosts and sites from #{LIB_PATH} to lib/tdd_deploy/"
  task :install do
    LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy')
    [ 'lib', LOCAL_TDD_DIR, File.join(LOCAL_TDD_DIR, 'local_tests')].each do |path|
      Dir.mkdir(path) unless File.exists? path
    end
    [ File.join(LIB_PATH, 'tdd_deploy', 'host_tests'), File.join(LIB_PATH, 'tdd_deploy', 'site_tests')].each do |src|
      FileUtils.cp_r src, LOCAL_TDD_DIR
    end
  end
end
