require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::SiteDatabase
  #
  #  tests to make sure a database named 'site' is defined in postgresql databases
  class SiteDatabase < TddDeploy::Base

    def test_site_db_defined
      deploy_test_on_all_hosts "#{self.site}\s*\|\s*#{self.site}", "database for #{self.site} should exist" do
        "psql --command='\\l' postgres postgres"
      end
    end
  end
end