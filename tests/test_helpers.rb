$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib/hosts', __FILE__)
$:.unshift File.expand_path('../lib/sites', __FILE__)

require 'test/unit'
require 'net/ssh'
require 'capistrano'

class HostTestCase < Test::Unit::TestCase
  attr_accessor :host_admin, :local_admin, :hosts, :local_admin_email

  def setup
    # see HostSetup.md/html for definitions of ADMIN & LOCAL_ADMIN
    @host_admin = ENV['HOST_ADMIN'] ? ENV['HOST_ADMIN'] : 'mike'
    @local_admin = ENV['LOCAL_ADMIN'] ? ENV['LOCAL_ADMIN'] : 'mike'
    @local_admin_email = ENV['LOCAL_ADMIN_EMAIL'] ? ENV['LOCAL_ADMIN_EMAIL'] : 'mike@clove.com'
    require 'capistrano'
    c = Capistrano::Configuration.new
    c.load 'Capfile'
    @hosts = c.roles[:hosts].map { |x| x.to_s }
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
