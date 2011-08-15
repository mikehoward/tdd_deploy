require 'rake'

x = eval File.new('tdd_deploy.gemspec').read
tdd_deploy_version = x.version.to_s

task :default => :test

desc "Run Unit Tests"
task :test do
  
end

desc "Create Gem"
task :gem do
  system 'gem build tdd_deploy.gemspec'
end
