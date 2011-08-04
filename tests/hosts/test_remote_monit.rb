$:.unshift File.expand_path('../..', __FILE__)

require 'test_helpers'

class TestRemoteMonit < HostTestCase

  def test_monit_installed
    run_on_all_hosts '/usr/bin/monit', "monit is not installed" do
     'ls /usr/bin/monit'
    end
  end

  def test_monit_running
    run_on_all_hosts /\smonit\s/, "monit is not running" do
     'ps -p `cat /var/run/monit.pid`'
    end
  end

end
