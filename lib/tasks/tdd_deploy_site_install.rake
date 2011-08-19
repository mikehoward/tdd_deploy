require 'rake'

desc 'Clean'
task :clean do
  ['monitrc', 'one_thin_server'].each do |fname|
    FileUtils.rm File.join('site', fname)
  end
  ['nginx.conf', 'thin.conf', 'thin_one_server.conf'].each do |fname|
    FileUtils.rm File.join('config', fname)
  end
end

desc 'Create Site Config & Site files'
task :create_site_files do
  require 'tdd_deploy_site_installer'
  
end