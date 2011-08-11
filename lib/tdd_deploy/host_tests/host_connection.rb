require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/assertions'

module TddDeploy
  class HostConnection
    include TddDeploy::Environ
    include TddDeploy::Assertions
    
    def ping
      require 'net/ping'
puts "self.hosts: #{self.hosts.inspect}"
      self.hosts.each do |host|
  puts "Tdd:Deploy#ping testing #{host}"
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