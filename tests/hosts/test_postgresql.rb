$:.unshift File.expand_path(File.dirname(__FILE__))

require 'test_host'

class TestRemotePostgresql < HostTestCase

  def test_postgresql_installed
    self.hosts.each do |host|
      run_in_ssh_session host, "/usr/bin/postgres\n", 'postgres not installed' do |host, login, admin|
        "ls /usr/bin/postgres"
      end
    end
  end

  def test_postgreql_running
    self.hosts.each do |host|
      run_in_ssh_session host, /postgres\s*\|\s*postgres/, "postgresql server not running" do
        "psql --command='\\l' postgres postgres"
      end
    end
  end
end
