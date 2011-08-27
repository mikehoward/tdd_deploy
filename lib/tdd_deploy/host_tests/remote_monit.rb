require 'tdd_deploy/test_base'

module TddDeploy
  # == TddDeploy::RemoteMonit
  #
  # verifies monit executable is present and running on all hosts
  class RemoteMonit < TddDeploy::TestBase
    def test_monit_installed
      deploy_test_file_exists_on_hosts_as self.host_admin, self.hosts, '/usr/bin/monit', 'monit should be installed'
    end

    def test_monit_running
      deploy_test_process_running_on_hosts_as 'root', self.hosts, '/var/run/monit.pid', "monit should be running"
    end
  end
end
