require 'tdd_deploy/test_base'

module TddDeploy
  # = TddDeploy::SiteUser
  #
  # tests all hosts to make sure that the local user can log on as *site_user*
  class SiteUser < TddDeploy::TestBase
    def test_login_as_site_user
      deploy_test_on_hosts_as self.site_user, self.hosts, "/home/#{self.site_user}", "should be able to log into host as #{self.site_user}" do
        'pwd'
      end
    end
  end
end