require 'tdd_deploy/base'

module TddDeploy
  class HostConnection < TddDeploy::Base
    def ping
      require 'net/ping'
      result = true
      self.hosts.each do |host|
        result &= assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
       end
       result
    end

    def ssh_login
      deploy_test_on_all_hosts "/home/#{self.host_admin}\n", "unable to connect via ssh" do
        'pwd'
      end
    end
    
    def ssh_login_as_root
      deploy_test_on_all_hosts_as 'root', '/root', "unable to connect as root via ssh" do
        'pwd'
      end
    end
  end
end