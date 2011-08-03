$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_host'

class TestRemoteMonit < HostTestCase

  def test_monit_installed
    self.hosts.each do |host|
      run_in_ssh_session host, '/usr/sbin/monit', "monit is not installed" do
        'ls /usr/sbin/monit'
      end
    end
  end

  def test_monit_running
    self.hosts.each do |host|
      run_in_ssh_session host, /\smonit\s/, "monit is not running" do
        'ps -p `cat /var/run/monit.pid`'
      end
    end
  end

end
