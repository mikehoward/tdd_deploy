require 'tdd_deploy/base'

module TddDeploy
  class HostConnection < TddDeploy::Base
    # ping - pings all hosts
    def ping
      require 'net/ping'
      result = true
      self.hosts.each do |host|
        result &= assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
       end
       result
    end

    # ssh_login - attempts to log in as *host_admin* on all hosts from current user
    def ssh_login
      deploy_test_on_all_hosts "/home/#{self.host_admin}\n", "unable to connect via ssh" do
        'pwd'
      end
    end
    
    # ssh_login_as_root - attempts to log in as *root* on all hosts from current user
    def ssh_login_as_root
      deploy_test_on_all_hosts_as 'root', '/root', "unable to connect as root via ssh" do
        'pwd'
      end
    end
  end
end