require 'tdd_deploy/base'

module TddDeploy
  class RemotePostgresql < TddDeploy::Base
    def test_postgresql_installed
      deploy_test_file_exists_on_all_hosts "/usr/bin/postgres", 'postgres should be installed'
    end

    def test_postgresql_running
      deploy_test_process_running_on_all_hosts_as 'root', '/var/lib/postgres/data/postmaster.pid', 'postgresql server should be running'
    end
  end
end
