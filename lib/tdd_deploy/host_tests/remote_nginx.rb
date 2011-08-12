require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/assertions'

module TddDeploy
  class RemoteNginx
    include TddDeploy::Environ
    include TddDeploy::Assertions
    include TddDeploy::DeployTestMethods

    def test_nginx_installed
      deploy_test_on_all_hosts '/usr/sbin/nginx', "nginx is not installed" do
        'ls /usr/sbin/nginx'
      end
    end

    def test_nginx_running
      deploy_test_on_all_hosts /\snginx\s/, "nginx is not running" do
        'ps -p `cat /var/run/nginx.pid`'
      end
    end
  end
end