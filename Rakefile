require 'rake'

x = eval File.new('tdd_deploy.gemspec').read
tdd_deploy_version = x.version.to_s

task :default => :test

desc "Run Unit Tests"
task :test do
  Dir.new('tests').each do |fname|
    system "ruby tests/" + fname if fname =~ /^test_/
  end
end

desc "Create Gem"
task :gem do
  system 'gem build tdd_deploy.gemspec'
  system "cp tdd_deploy-#{tdd_deploy_version}.gem ~/Rails/GemCache/gems/"
  system "(cd ~/Rails/GemCache ; gem generate_index -d . )"
end
