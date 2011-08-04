$:.unshift File.expand_path('../..', __FILE__)
require 'test_helpers'

class  HostHelpersTestCase < HostTestCase

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
