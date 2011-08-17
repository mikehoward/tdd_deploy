require 'tdd_deploy/base'

module TddDeploy
  class RemoteNginx < TddDeploy::Base
    def test_nginx_installed
      deploy_test_on_all_hosts '/usr/sbin/nginx', "nginx should be installed" do
        'ls /usr/sbin/nginx'
      end
    end

    def test_nginx_running
      deploy_test_on_all_hosts /\snginx\s/, "nginx shold be running" do
        'ps -p `cat /var/run/nginx.pid`'
      end
    end
  end
end