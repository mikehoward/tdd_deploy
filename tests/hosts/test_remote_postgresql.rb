$:.unshift File.expand_path('../..', __FILE__)

require 'test_helpers'

class TestRemotePostgresql < HostTestCase

  def test_postgresql_installed
    run_on_all_hosts "/usr/bin/postgres\n", 'postgres not installed' do |host, login, admin|
      "ls /usr/bin/postgres"
    end
  end

  def test_postgreql_running
    run_on_all_hosts /postgres\s*\|\s*postgres/, "postgresql server not running" do
      "psql --command='\\l' postgres postgres"
    end
  end
end
