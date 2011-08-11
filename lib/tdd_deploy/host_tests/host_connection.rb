require 'test/unit'
module TddDeploy
  class HostConnection

    def ping
      require 'net/ping'
      self.hosts.each do |host|
        assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
       end
    end

    def ssh_login
      deploy_test_on_all_hosts "/home/#{self.host_admin}\n", "unable to connect via ssh" do
        'pwd'
      end
    end
  end
end