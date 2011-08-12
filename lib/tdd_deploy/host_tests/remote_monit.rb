require 'test/unit'
require 'tdd_deploy/environ'
require 'tdd_deploy/assertions'

module TddDeploy
  class RemoteMonit
    include TddDeploy::Environ
    include TddDeploy::Assertions
    include TddDeploy::DeployTestMethods

    def test_monit_installed
      deploy_test_on_all_hosts '/usr/bin/monit', "monit is not installed" do
       'ls /usr/bin/monit'
      end
    end

    def test_monit_running
      deploy_test_on_all_hosts /\smonit\s/, "monit is not running" do
       'ps -p `cat /var/run/monit.pid`'
      end
    end
  end
end
