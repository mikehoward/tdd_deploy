$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'

# ENV.each do |k, v|
#   puts "#{k}: #{v}" if k =~ /SITE|HOST|LOCAL/
# end

class  HostHelpersTestCase < HostTestCase

  def setup
    ENV['HOST_ADMIN'] = 'mike'
    ENV['LOCAL_ADMIN'] = 'mike'
    ENV['LOCAL_ADMIN_EMAIL'] = 'mike@clove.com'
    ENV['HOSTS'] = 'arch'
    super
  end

  def test_default_env
    # this idiocy removes the environment variables that setup uses in this test
    # and calls self.super.setup (if that were actually possible)
    ['HOST_ADMIN', 'LOCAL_ADMIN', 'LOCAL_ADMIN_EMAIL', 'HOSTS'].each { |x| ENV.delete x }
    super_setup = HostTestCase.instance_method :setup
    bound_super_setup = super_setup.bind self
    bound_super_setup.call

    assert_equal 'host_admin', self.host_admin, "host_admin should be 'host_admin'"
    assert_equal 'local_admin', self.local_admin, "local_admin should be 'local_admin'"
    assert_equal 'local_admin@example.com', self.local_admin_email, "local_admin_email should be 'local_admin@example.com'"
#    assert_equal 'hosts', self.hosts, "hosts should be 'arch'"
    assert_equal ['arch'], self.hosts, "hosts should be 'arch'"
  end

  def test_custom_env
    assert_equal 'mike', self.host_admin, "host_admin should be 'mike'"
    assert_equal 'mike', self.local_admin, "local_admin should be 'mike'"
    assert_equal 'mike@clove.com', self.local_admin_email, "local_admin_email should be 'mike@clove.com'"
#    assert_equal 'hosts', self.hosts, "hosts should be 'arch'"
    assert_equal ['arch'], self.hosts, "hosts should be 'arch'"
  end

  def test_run_in_ssh_session_as
    assert_raises ArgumentError do
      run_in_ssh_session_as 'root', self.hosts.first, '', 'session catches empty match expression' do
        'uname -a'
      end
    end

    assert_raises ::MiniTest::Assertion do
      run_in_ssh_session_as 'root', self.hosts.first, 'no-file-exists', 'generate an error' do
        'ls /usr/no-file-exists'
      end
    end

    run_in_ssh_session_as 'root', self.hosts.first, "/root", 'can\'t run on host' do
      'pwd'
    end
  end

  def test_run_in_ssh_session
    run_in_ssh_session self.hosts.first, "/home/#{self.host_admin}", "can't run as #{self.host_admin} on host" do
      'pwd'
    end
  end

  def test_run_on_all_hosts_as
    run_on_all_hosts_as 'root', '/root', "can't run as root on all hosts" do
      'pwd'
    end
  end

  def test_run_on_all_hosts
    run_on_all_hosts "/home/#{self.host_admin}", 'can\'t run on some hosts' do
      'pwd'
    end
  end
end
