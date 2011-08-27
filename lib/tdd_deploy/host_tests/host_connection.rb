require 'tdd_deploy/test_base'

module TddDeploy
  # == TddDeploy::HostConnection
  #
  # tests that hosts are pingable and that the current user can log in as both 'host_admin' and 'root'
  class HostConnection < TddDeploy::TestBase
    # ping - pings all hosts
    def ping
      result = true
      self.hosts.each do |host|
        result &= assert host, ping_host(host), "Host #{host} should respond to ping"
       end
       result
    end

    # ssh_login - attempts to log in as *host_admin* on all hosts from current user
    def ssh_login
      deploy_test_on_hosts_as self.host_admin, self.hosts, "/home/#{self.host_admin}\n", "should be able to connect via ssh" do
        'pwd'
      end
    end
    
    # ssh_login_as_root - attempts to log in as *root* on all hosts from current user
    def ssh_login_as_root
      deploy_test_on_hosts_as 'root', self.hosts, '/root', "Should be able to connect as root via ssh" do
        'pwd'
      end
    end
  end
end