$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib/hosts', __FILE__)
$:.unshift File.expand_path('../lib/sites', __FILE__)

require 'test/unit'
require 'net/ssh'
require 'capistrano'

class HostTestCase < Test::Unit::TestCase
  attr_accessor :host_admin, :hosts, :local_admin_email, :local_admin

  def setup
    # see HostSetup.md/html for definitions of ADMIN & LOCAL_ADMIN
    @host_admin = ENV['HOST_ADMIN'] ? ENV['HOST_ADMIN'] : 'host_admin'
    @local_admin = ENV['LOCAL_ADMIN'] ? ENV['LOCAL_ADMIN'] : 'local_admin'
    @local_admin_email = ENV['LOCAL_ADMIN_EMAIL'] ? ENV['LOCAL_ADMIN_EMAIL'] : 'local_admin@example.com'
    if ENV['HOSTS']
      @hosts = ENV['HOSTS'].split
    else
      require 'capistrano'
      c = Capistrano::Configuration.new
      c.load 'Capfile'
      @hosts = c.roles[:hosts].map { |x| x.to_s }
    end
  end

  def run_on_all_hosts(match_expr_or_str, err_msg, &block)
    run_on_all_hosts_as self.host_admin, match_expr_or_str, err_msg, &block
  end

  def run_on_all_hosts_as(userid, match_expr_or_str, err_msg, &block)
    self.hosts.each do |host|
      run_in_ssh_session_as userid, host, match_expr_or_str, err_msg, &block
    end
  end

  # run_in_ssh_session host, match_exp_or_string, err_msg, &block
  def run_in_ssh_session(host, match, err_msg, &block)
    run_in_ssh_session_as(self.host_admin, host, match, err_msg, &block)
  end

  def run_in_ssh_session_as(userid, host, match, err_msg, &block)
    login = "#{userid}@#{host}"
    match = Regexp.new(match) if match.is_a? String
    raise ArgumentError, 'match expression cannot be empty' if match =~ ''

    begin
      ssh_session = Net::SSH.start(host, userid)

      cmd = block.call(host, login, userid)
      rsp = ''
      err_rsp = nil

      ssh_session.open_channel do |channel|
        channel.exec(cmd) do |ch, success|
          ch.on_data do |ch, data|
            rsp ||= ''
            rsp += data.to_s
          end

          ch.on_extended_data do |ch, data|
            err_rsp ||= ''
            err_rsp += data.to_s
          end

        end
      end

      # must do this or the channel only runs once
      ssh_session.loop

      flunk "Host: #{host}: command generated error data:\n  command: #{cmd}\n rsp: '#{rsp}\n err rsp: '#{err_rsp}'" \
        if err_rsp

      refute_nil rsp, "Host: #{host}: stdout is empty for command '#{cmd}'"

      assert_match match, rsp, "Host: #{host}: #{err_msg}\n rsp: #{rsp}"

      ssh_session.close
    rescue Exception => e
      flunk("error talking to #{host} as #{userid}: #{e.message}")
      ssh_session.shutdown! if ssh_session instance_of? Capistrano::SSH
    end
  end
end


class SiteTestCase < HostTestCase
  attr_accessor :site, :site_user, :site_base_port, :site_num_servers

  def setup
    super
    @site = ENV['SITE'] ? ENV['SITE'] : 'site'
    @site_user = ENV['SITE_USER'] ? ENV['SITE_USER'] : 'site'
    @site_base_port = ENV['SITE_BASE_PORT'] ? ENV['SITE_BASE_PORT'].to_i : 8000
    @site_num_servers = ENV['SITE_NUM_SERVERS'] ? ENV['SITE_NUM_SERVERS'].to_i : 3
  end
end
