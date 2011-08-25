require 'fileutils'
LIB_PATH = File.expand_path('../..', __FILE__)
LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy')

namespace :tdd_deploy do
  desc "deletes tests in lib/tdd_deploy/host_tests & site_tests"
  task :flush_gem_tests do
    ['host_tests', 'site_tests'].each do |target_dir|
      target_path = File.join(LOCAL_TDD_DIR, target_dir)
      FileUtils.rm_r target_path if File.exists? target_path
    end
  end
  
  desc "deletes tdd_deploy_configs/ & all it's files"
  task :rm_configs do
    tdd_deploy_configs = './tdd_deploy_configs'
    FileUtils.rm_r tdd_deploy_configs if File.exists? tdd_deploy_configs
  end
  
  desc "copies tests & config templates to lib/tdd_deploy/"
  task :install do
    LOCAL_TDD_DIR = File.join('lib', 'tdd_deploy')
    [ 'lib', LOCAL_TDD_DIR, File.join(LOCAL_TDD_DIR, 'local_tests')].each do |path|
      Dir.mkdir(path) unless File.exists? path
    end
    [ File.join(LIB_PATH, 'tdd_deploy', 'host_tests'),
      File.join(LIB_PATH, 'tdd_deploy', 'site_tests'),
      File.join(LIB_PATH, 'tdd_deploy', 'site-erb')].each do |src|
      FileUtils.cp_r src, LOCAL_TDD_DIR
    end
  end
end
