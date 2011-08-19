require 'tdd_deploy/base'

module TddDeploy
  class RemoteMonit < TddDeploy::Base
    def test_monit_installed
      deploy_test_file_exists_on_all_hosts '/usr/bin/monit', 'monit should be installed'
    end

    def test_monit_running
      deploy_test_process_running_on_all_hosts '/var/run/monit.pid', "monit should be running"
    end
  end
end
