require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::RemotePostgresql
  #
  # verifies that the postgresql exectuable is both installed and running on db_hosts
  class RemotePostgresql < TddDeploy::Base
    def test_postgresql_installed
      deploy_test_file_exists_on_hosts_as 'root', self.db_hosts, "/usr/bin/postgres", 'postgres should be installed'
    end

    def test_postgresql_running
      deploy_test_process_running_on_hosts_as 'root', self.db_hosts, '/var/lib/postgres/data/postmaster.pid', 'postgresql server should be running'
    end
  end
end
