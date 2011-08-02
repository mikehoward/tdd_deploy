require 'test_helpers'

describe "can communicate with host" do
  before(:all) do
    @user = 'fred' # 'mike'

    require 'capistrano'
    c = Capistrano::Configuration.new
    c.load 'Capfile'
    @hosts = c.roles[:hosts].map { |x| x.to_s }
  end

  it "ping" do
    require 'net/ping'
    @hosts.each do |host|
      # puts "#{host} work"
      Net::Ping::External.new(host).should be_ping
    end
  end

  it "should connect via ssh" do
    @hosts.each do |host|
      # puts "ssh'ing into #{@user}@#{host}"
      server_def = Capistrano::ServerDefinition.new("#{@user}@#{host}")
      ssh_session = Capistrano::SSH.connect(server_def)
      ssh_session.should_not be_nil
    end
  end
end

