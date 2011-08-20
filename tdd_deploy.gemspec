require './lib/tdd_deploy/version'
Gem::Specification.new do |s|
  s.name = 'tdd_deploy'
  s.version = TddDeploy::VERSION
  s.required_ruby_version = '>= 1.9.2'
  
  s.authors = ["Mike Howard"]
  s.date = '2011-08-16'
  s.summary = %q{ Test driven support for host provisioning & Capistrano deployment - for those who don't want to bother learning too much }
  s.description = s.summary
  s.email = %q{ mike@clove.com }
  s.files = %w{ Capfile Gemfile config.ru } + Dir['bin/*'] +
      Dir['lib/**/*.rb'] + Dir['tests/test*.rb'] + Dir['lib/tasks/*.rake']

  s.homepage = 'https://github.com/mikehoward/tdd_deploy'
  s.licenses = ["GPL3"]
  
  s.executables = ['tdd_deploy_context', 'tdd_deploy_server', 'tdd_deploy_site_installer']

  s.require_paths = ["lib"]
  s.rubygems_version = %q{ 1.6.2 }
  
  s.add_dependency('capistrano')
  s.add_dependency('net-ping')
  s.add_dependency('net-ssh')

  s.add_development_dependency('ZenTest', "~> 4.5.0")
  s.add_development_dependency('autotest-growl')

end