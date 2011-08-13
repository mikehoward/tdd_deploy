require 'tdd_deploy/base'

module TddDeploy
  class RemotePostgresql < TddDeploy::Base
    def test_postgresql_installed
      deploy_test_on_all_hosts "/usr/bin/postgres\n", 'postgres not installed' do |host, login, admin|
        "ls /usr/bin/postgres"
      end
    end

    def test_postgresql_running
      deploy_test_on_all_hosts /postgres\s*\|\s*postgres/, "postgresql server not running" do
        "psql --command='\\l' postgres postgres"
      end
    end
  end
end
