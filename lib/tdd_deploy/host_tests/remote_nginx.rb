require 'tdd_deploy/base'

module TddDeploy
  class RemoteNginx < TddDeploy::Base
    def test_nginx_installed
      deploy_test_file_exists_on_all_hosts '/usr/sbin/nginx', "nginx should be installed"
    end

    def test_nginx_running
      deploy_test_process_running_on_all_hosts '/var/run/nginx.pid', "nginx shold be running"
    end
  end
end