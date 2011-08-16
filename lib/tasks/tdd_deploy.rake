require 'fileutils'
LIB_PATH = File.expand_path('../lib', __FILE__)

namespace :tdd_deploy do
  desc "uninstall tdd_deploy tests"
  task :uninstall do
    LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy', 'tests')
    File.rm_r LOCAL_TDD_DIR if File.exists? LOCAL_TDD_DIR
  end
  
  desc "install tdd_deploy copies tests for hosts and sites from #{LIB_PATH} to lib/tdd_deploy/"
  task :install do
    puts "I am #{LIB_PATH}"
    puts "You are here: #{Dir.pwd}"
    LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy', 'tests')
    [ 'lib', File.join('lib', 'tdd_deploy'), LOCAL_TDD_DIR].each do |path|
      Dir.mkdir(path) unless File.exists? path
    end
    [ File.join(LIB_PATH, 'tdd_deploy', 'host_tests', '.'), File.join(LIB_PATH, 'tdd_deploy', 'site_tests', '.')].each do |src|
      File.cp_r src, LOCAL_TDD_DIR
    end
  end
end
