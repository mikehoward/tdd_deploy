require 'tdd_deploy/base'

module TddDeploy
  class RemotePostfix < TddDeploy::Base
    def test_postfix_installed
      deploy_test_file_exists_on_hosts_as 'root', self.hosts, '/usr/sbin/postfix', "postfix should be installed"
    end

    def test_postfix_running
      deploy_test_process_running_on_hosts_as 'root', self.hosts, '/var/spool/postfix/pid/master.pid', "postfix should be running"
    end

    def test_postfix_accepts_mail
      deploy_test_on_hosts_as self.host_admin, self.hosts, "mail works\n", 'postfix accepts mail' do |host, login, userid|
        "echo \"test mail\" | mail -s 'test mail' -r #{userid}@#{host} #{self.local_admin_email} && echo 'mail works'"
      end
    end
  end
end
