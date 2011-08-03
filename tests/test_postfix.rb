$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_helpers'

class TestRemotePostfix < HostTestCase

  def test_postfix_installed
    self.hosts.each do |host|
      run_in_ssh_session host, '/usr/sbin/postfix', "postfix is not installed" do
        'ls /usr/sbin/postfix'
      end
    end
  end

  def test_postfix_running
    self.hosts.each do |host|
      run_in_ssh_session host, /\spostfix\s/, "postfix is not running" do
        'ps -p `cat /var/run/postfix.pid`'
      end
    end
  end

end
