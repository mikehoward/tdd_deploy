Gem::Specification.new do |s|
  s.name = %q{ tdd_deploy }
  s.version = "0.0.1"
  
  s.Authors = ["Mike Howard"]
  s.date = %q{ 2011-08-09 }
  s.summary = %q{ Test driven support for host provisioning & Capistrano deployment - for those who don't want to bother learning too much }
  s.description = s.summary
  s.email = %q{ mike@clove.com }
  s.files = %w{
    Capfile
    Gemfile

    HostSetup.md
    README.md
    SiteSetup.md
    
    lib/tdd_deploy.rb
    lib/tdd_deploy/deploy_test_methods.rb
    lib/tdd_deploy/environ.rb
    lib/tdd/run_methods.rb
    lib/tdd_deploy_tests/*
    
    tests/test_environ.rb
    tests/test_helpers.rb
    tests/test_run_methods.rb
    tests/test_set_env.rb
    tests/test_tdd_deploy.rb
    tests/test_test_deploy_methods.rb
    }
    s.homepage = %q{ https://github.com/mikehoward/tdd_deploy }
    s.licenses = ["MIT"]
    s.require_paths = ["lib"]
    s.rubygems_version = %q{ 1.6.2 }
    
    s.add_dependency(
    # FIXME!!!!!
    )
end