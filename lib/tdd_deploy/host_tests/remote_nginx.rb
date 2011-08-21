require 'tdd_deploy/base'

module TddDeploy
  class RemoteNginx < TddDeploy::Base
    def test_nginx_installed
      deploy_test_file_exists_on_hosts_as self.host_admin, self.web_hosts + self.balance_hosts, '/usr/sbin/nginx', "nginx should be installed"
    end

    def test_nginx_running
      deploy_test_process_running_on_hosts_as self.host_admin, self.web_hosts + self.balance_hosts, '/var/run/nginx.pid', "nginx shold be running"
    end
  end
end