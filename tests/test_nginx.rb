$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_helpers'

class TestRemoteNginx < HostTestCase

  def test_nginx_installed
    self.hosts.each do |host|
      run_in_ssh_session host, '/usr/sbin/nginx', "nginx is not installed" do
        'ls /usr/sbin/nginx'
      end
    end
  end

  def test_nginx_running
    self.hosts.each do |host|
      run_in_ssh_session host, /\snginx\s/, "nginx is not running" do
        'ps -p `cat /var/run/nginx.pid`'
      end
    end
  end

end
