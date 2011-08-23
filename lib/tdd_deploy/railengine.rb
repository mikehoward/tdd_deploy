module TddDeploy
  # == TddDeploy::Engine
  #
  # brings in the rake tasks. Ignore it
  class Engine < Rails::Engine
    # engine_name "tdd_deploy"
    rake_tasks do
      load "tdd_deploy/../tasks/tdd_deploy.rake"
    end
    initializer 'active_support.add_tdd_deploy' do
    end
  end
end
