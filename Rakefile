require 'rake'

x = eval File.new('tdd_deploy.gemspec').read
tdd_deploy_version = x.version.to_s

task :default => :test

desc "Run Unit Tests"
task :test do
  autotest
end

desc "Create Gem"
task :gem do
  system 'gem build tdd_deploy.gemspec'
  system "cp tdd_deploy-#{tdd_deploy_version}.gem ~/Rails/GemCache/gems/"
  system "(cd ~/Rails/GemCache ; gem generate_index -d . )"
end

desc "Push Gem to rubygems"
task :push do
  system "gem push tdd_deploy-#{tdd_deploy_version}.gem"
end
