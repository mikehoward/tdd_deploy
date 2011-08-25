require 'rake'
require 'fileutils'

x = eval File.new('tdd_deploy.gemspec').read
tdd_deploy_version = x.version.to_s

task :default => :test

desc "Run Unit Tests"
task :test do
  autotest
end

desc "Create Gem"
task :gem => :html do
  system 'gem build tdd_deploy.gemspec'
  system "cp tdd_deploy-#{tdd_deploy_version}.gem ~/Rails/GemCache/gems/"
  system "(cd ~/Rails/GemCache ; gem generate_index -d . )"
end

desc "Create Yard Doc"
task :doc do
  FileUtils.rm_r 'doc' if File.exists? 'doc'
  system 'yard'
end

desc "Push Gem to rubygems"
task :push_gem do
  system "gem push tdd_deploy-#{tdd_deploy_version}.gem"
end

desc "Create html from .md files"
task :html do
  Dir.new('.').each do |fname|
    next unless fname =~ /.md$/
    fname_html = File.basename(fname, '.md') + '.html'
    system "redcarpet #{fname} | sed -e 's/VERSION/#{TddDeploy::VERSION}/' > #{fname_html}"
  end
end
