$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_helpers'
require 'capistrano'

class TestHostConnection < Test::Unit::TestCase

  def setup
    @user =  'mike'
    require 'capistrano'
    c = Capistrano::Configuration.new
    c.load 'Capfile'
    @hosts = c.roles[:hosts].map { |x| x.to_s }
  end

  def test_true
    assert true, "True is True"
  end

  def test_ping
    require 'net/ping'
    @hosts.each do |host|
      # puts "#{host} work"
      # Net::Ping::External.new(host).should be_ping
      assert Net::Ping::External.new(host).ping?, "Host #{host} should respond to ping"
     end
  end

  def test_ssh_login
    @hosts.each do |host|
      # puts "ssh'ing into #{@user}@#{host}"
      login = "#{@user}@#{host}"
      server_def = Capistrano::ServerDefinition.new(login)
      begin
        ssh_session = Capistrano::SSH.connect(server_def)
        assert_equal "/home/#{@user}\n", (tmp = ssh_session.exec!('pwd')), "received: #{tmp}"
      rescue Exception => e
        flunk("ssh error talking to #{login}: #{e.message}")
      end
    end
  end

  def test_postgreql_running
    @hosts.each do |host|
      login = "#{@user}@#{host}"
      server_def = Capistrano::ServerDefinition.new(login)
      begin
        ssh_session = Capistrano::SSH.connect(server_def)
        tmp = ssh_session.exec! "psql --command='\\l' postgres postgres"
        refute_nil tmp
        assert_match /postgres\s*\|\s*postgres/, tmp, "posgresql server not running on #{host}"
      rescue Exception => e
        flunk("ssh error talking to #{login}: #{e.message}")
      end
    end
  end

  def test_nginx_running
    @hosts.each do |host|
      login = "#{@user}@#{host}"
      server_def = Capistrano::ServerDefinition.new(login)
      begin
        ssh_session = Capistrano::SSH.connect(server_def)
        tmp = ssh_session.exec! 'ps -p `cat /var/run/nginx.pid`'
        refute_nil tmp
        assert_match /\snginx\s/, tmp, "nginx not running on #{host}"
      rescue Exception => e
        flunk("ssh error talking to #{login}: #{e.message}")
      end
    end
  end

end
