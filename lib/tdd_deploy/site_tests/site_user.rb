require 'tdd_deploy/base'

module TddDeploy
  # = TddDeploy::SiteUser
  #
  # tests all hosts to make sure that the local user can log on as *site_user*
  class SiteUser < TddDeploy::Base
    def test_login_as_site_user
      deploy_test_on_all_hosts_as self.site_user, "/home/#{self.site_user}", "unable to log into host as #{self.site_user}" do
        'pwd'
      end
    end
  end
end