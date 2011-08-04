$:.unshift File.expand_path('../..', __FILE__)

require 'test_helpers'

class TestRemoteNginx < HostTestCase

  def test_nginx_installed
    run_on_all_hosts '/usr/sbin/nginx', "nginx is not installed" do
      'ls /usr/sbin/nginx'
    end
  end

  def test_nginx_running
    run_on_all_hosts /\snginx\s/, "nginx is not running" do
      'ps -p `cat /var/run/nginx.pid`'
    end
  end
end
