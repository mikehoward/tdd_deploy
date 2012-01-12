require 'rake'
require 'fileutils'

x = eval File.new('tdd_deploy.gemspec').read
tdd_deploy_version = x.version.to_s

task :default => :test

desc "Run Unit Tests"
task :test do
  system 'bundle exec autotest'
end

desc "Create Gem"
task :gem => :html do
  system 'gem build tdd_deploy.gemspec'
  system "cp tdd_deploy-#{tdd_deploy_version}.gem ~/Rails/GemCache/gems/"
  system "(cd ~/Rails/GemCache ; gem generate_index -d . )"
end

desc "Remove Yard doc directory"
task :rm_doc do
  FileUtils.rm_r 'doc' if File.exists? 'doc'
end

desc "Create Yard Doc"
task :doc => :rm_doc do
  system 'yard'
end

desc "Push Gem to rubygems"
task :push_gem do
  system "gem push tdd_deploy-#{tdd_deploy_version}.gem"
end

desc "Create html from .md files"
task :html do
  doc_dir = File.join('lib', 'tdd_deploy', 'doc')
  Dir.new(doc_dir).each do |fname|
    next unless fname =~ /.md$/
    file_path = File.join(doc_dir, fname)
    fname_html = File.join(doc_dir, File.basename(fname, '.md') + '.html')
    system "redcarpet #{file_path} | sed -e 's/VERSION/#{TddDeploy::VERSION}/' > #{fname_html}"
  end
end
