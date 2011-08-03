$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_helpers'

class TestHostConnection < HostTestCase

#  def setup
#    super
#  end

  def test_ping
    require 'net/ping'
    self.hosts.each do |host|
      # puts "#{host} work"
      # Net::Ping::External.new(host).should be_ping
      assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
     end
  end

  def test_ssh_login
    self.hosts.each do |host|
      # puts "ssh'ing into #{@user}@#{host}"
      login = "#{self.admin}@#{host}"
      server_def = Capistrano::ServerDefinition.new(login)
      begin
        ssh_session = Capistrano::SSH.connect(server_def)
        assert_equal "/home/#{self.admin}\n", (tmp = ssh_session.exec!('pwd')), "received: #{tmp}"
      rescue Exception => e
        flunk("ssh error talking to #{login}: #{e.message}")
      end
    end
  end

end
