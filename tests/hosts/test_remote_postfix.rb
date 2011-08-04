$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_host'

class TestRemotePostfix < HostTestCase

  def test_postfix_installed
    run_on_all_hosts '/usr/sbin/postfix', "postfix is not installed" do
      'ls /usr/sbin/postfix'
    end
  end

  def test_postfix_running
    run_on_all_hosts_as 'root', /\smaster\s/, "postfix is not running" do
      'ps -p `cat /var/spool/postfix/pid/master.pid`'
    end
  end

  def test_postfix_accepts_mail
    run_on_all_hosts "mail works\n", 'postfix accepts mail' do |host, login, userid|
      "echo \"test mail\" | mail -s 'test mail' -r #{userid}@#{host} #{self.local_admin_email} && echo 'mail works'"
    end
  end
end
