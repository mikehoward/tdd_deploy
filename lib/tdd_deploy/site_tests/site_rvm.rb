require 'tdd_deploy/base'

module TddDeploy
  # = TddDeploy::SiteUser
  #
  # tests all hosts to make sure that the local user can log on as *site_user*
  class SiteRvm < TddDeploy::Base
    def test_rvm
      deploy_test_on_hosts_as self.site_user, self.app_hosts, /RVM is the Ruby/, "rvm should be installed" do
        'source ~/.rvm/scripts/rvm ;  rvm'
      end
    end

    def test_rvm_current
      deploy_test_on_hosts_as self.site_user, self.app_hosts, /(ruby|jruby|rbx|ree)-\d\.\d\.\d/, "rvm current should display a ruby" do
        'source ~/.rvm/scripts/rvm ; rvm current'
      end
    end
    
    def test_bundle_prescence
      deploy_test_on_hosts_as self.site_user, self.app_hosts, /Bundler version/, "bundler should run" do
        'source ~/.rvm/scripts/rvm ; bundle --version'
      end
    end
  end
end