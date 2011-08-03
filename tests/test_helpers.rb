$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib/hosts', __FILE__)
$:.unshift File.expand_path('../lib/sites', __FILE__)

require 'test/unit'
require 'net/ssh'
require 'capistrano'


class HostTestCase < Test::Unit::TestCase
  attr_accessor :admin, :ladmin, :hosts

  def setup
    # see HostSetup.md/html for definitions of ADMIN & LADMIN
    @admin =  'mike'
    @ladmin = 'mike'
    require 'capistrano'
    c = Capistrano::Configuration.new
    c.load 'Capfile'
    @hosts = c.roles[:hosts].map { |x| x.to_s }
  end

  def run_on_all_hosts(match_expr_or_str, err_msg, &block)
    self.hosts.each do |host|
      run_in_ssh_session host, match_expr_or_str, err_msg, &block
    end
  end

  # run_in_ssh_session host, match_exp_or_string, err_msg, &block
  def run_in_ssh_session(host, match, err_msg, &block)
    login = "#{self.admin}@#{host}"
    raise 'match expression cannot be empty' if match.empty?
    match = Regexp.new(match) if match.is_a? String

    begin
      ssh_session = Net::SSH.start(host, self.admin)

      cmd = block.call(host, login, self.admin)
      rsp = ''

      ssh_session.open_channel do |channel|
        channel.exec(cmd) do |ch, success|
          ch.on_data do |ch, data|
            rsp ||= ''
            rsp += data
          end

          ch.on_extended_data do |ch, data|
            flunk "Host: #{host}: command generated error data:\n  command: #{cmd}\n  err rsp: '#{data}'"
          end

        end
      end

      # must do this or the channel only runs once
      ssh_session.loop

      refute_nil rsp, "Host: #{host}: stdout is empty for command '#{cmd}'"

      assert_match match, rsp, "Host: #{host}: #{err_msg}\n rsp: #{rsp}"

      ssh_session.close
    rescue Exception => e
      flunk("error talking to #{host} as #{self.admin}: #{e.message}")
      ssh_session.shutdown! if ssh_session instance_of? Capistrano::SSH
    end
  end


  def test_run_in_ssh_session
    assert_raises RuntimeError do
      run_in_ssh_session self.hosts.first, '', 'session catches empty match expression' do
        'uname -a'
      end
    end

    assert_raises ::MiniTest::Assertion do
      run_in_ssh_session self.hosts.first, 'no-file-exists', 'generate an error' do
        'ls /usr/no-file-exists'
      end
    end

    run_in_ssh_session self.hosts.first, "/home/#{self.admin}", 'can\'t run on host' do
      'pwd'
    end
  end

  def test_run_on_all_hosts
    run_on_all_hosts "/home/#{self.admin}", 'can\'t run on some hosts' do
      'pwd'
    end
  end
end
