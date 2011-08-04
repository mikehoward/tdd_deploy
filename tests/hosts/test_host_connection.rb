$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_host'

class TestHostConnection < HostTestCase

  def test_ping
    require 'net/ping'
    self.hosts.each do |host|
      assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
     end
  end

  def test_ssh_login
    run_on_all_hosts "/home/#{self.host_admin}\n", "unable to connect via ssh" do
      'pwd'
    end
  end

end
