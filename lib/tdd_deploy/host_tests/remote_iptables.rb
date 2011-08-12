require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/assertions'

module TddDeploy
  class IpTables
    include TddDeploy::Environ
    include TddDeploy::Assertions
    include TddDeploy::DeployTestMethods

    def tcp_some_blocked_ports
      self.hosts.each do |host|
        # Linode seems to refuse to block 21 - FTP control
        #  [20, 21, 23, 25, 53, 5432, 2812].each do |port|
        [20, 23, 25, 53, 5432, 2812].each do |port|
          tcp_socket = TCPSocket.new(host, port) rescue 'failed'
          assert_equal 'failed', tcp_socket, "Host: #{host}: Should not be able to connect via tcp to port #{port}"
        end
      end
    end

    def udp_some_blocked_ports
      self.hosts.each do |host|
        # Linode seems to refuse to block 21 - FTP control
        #  [20, 21, 23, 25, 53, 5432, 2812].each do |port|
        [20, 23, 25, 53, 5432, 2812].each do |port|
          udp_socket = UDPSocket.new(host, port) rescue 'failed'
          assert_equal 'failed', udp_socket, "Host: #{host}: Should not be able to connect via udp to port #{port}"
        end
      end
    end
  end
end
