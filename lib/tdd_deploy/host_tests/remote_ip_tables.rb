require 'tdd_deploy/test_base'

module TddDeploy
  # == TddDeploy::RemoteIpTables
  #
  # checks to see if iptables is working by attempting to connect to each host on a collection
  # of 'interesting' ports. the ports probed are: 20, 23, 25, 53, 5432, 2812
  #
  class RemoteIpTables < TddDeploy::TestBase
    # tcp_some_blocked_ports - checks TCP ports
    def tcp_some_blocked_ports
      @port_to_check ||= [20, 23, 25, 53, 5432, 2812]
      self.hosts.each do |host|
        result = true
        # Linode seems to refuse to block 21 - FTP control
        #  [20, 21, 23, 25, 53, 5432, 2812].each do |port|
        if self.ping_host(host)
          @port_to_check.each do |port|
            tcp_socket = TCPSocket.new(host, port) rescue 'failed'
            unless tcp_socket == 'failed'
              result &= fail host, "Host: #{host}: iptables test: Should not be able to connect via tcp to port #{port}"
            end
          end
          pass host, "tcp ports #{@port_to_check.join(',')} blocked"
        else
          fail host, "Host: #{host}: iptables cannot be tested - host does not respond to ping"
        end
      end
    end

    # Unfortunately, this doesn't work with UDP. I'd need a resonder on the server
    # to see if the ports were blocked & I don't have one.
    # udp_some_blocked_ports - checks UDP ports
    # def udp_some_blocked_ports
    #   self.hosts.each do |host|
    #     # Linode seems to refuse to block 21 - FTP control
    #     #  [20, 21, 23, 25, 53, 5432, 2812].each do |port|
    #     [20, 23, 25, 53, 5432, 2812].each do |port|
    #       # udp_socket = UDPSocket.new(host, port) rescue 'failed'
    #       udp_socket = UDPSocket.new
    #       udp_socket.bind(host, port) rescue 'failed to bind'
    #       assert_equal host, 'failed', udp_socket, "Host: #{host}: Should not be able to connect via udp to port #{port}"
    #     end
    #   end
    # end
  end
end
