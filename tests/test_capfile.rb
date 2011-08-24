$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/capfile'

class TestCapfileTestCase < Test::Unit::TestCase
  
  def setup
    @capfile = TddDeploy::Capfile.new
  end
  
  def teardown
    @capfile = nil
  end
  
  def test_load_recipes
    assert_raises LoadError, "@capfile.load_recipes(no-file) should fail" do
      @capfile.load_recipes('no-file')
    end
    assert @capfile.load_recipes('./config/deploy.rb'), "@capfile should load recipies"
  end

  def test_role_keys
    @capfile.load_recipes('./config/deploy.rb')
    assert_equal [:app, :db, :web], @capfile.roles.keys.sort, "capfile roles should be app, db, web"
  end
  
  def test_role_values
    @capfile.load_recipes  # ('./config/deploy.rb')
    assert_equal ['app1', 'app2', 'app3'], @capfile.roles[:app].servers.map {|x| x.to_s }.sort, "app servers should be app1, app2, app3"
    assert_equal ['db2', 'db3', 'db_primary'], @capfile.roles[:db].servers.map {|x| x.to_s }.sort, "db servers should be db_primary, db2, db3"
    assert_equal ['web1', 'web2'], @capfile.roles[:web].servers.map {|x| x.to_s }.sort, "web servers should be web1, web2"
  end

  def test_role_to_host_list
    @capfile.load_recipes('./config/deploy.rb')
    assert_equal ['app1', 'app2', 'app3'], @capfile.role_to_host_list(:app).sort, "app servers should be app1, 2, 3"
  end
  
  def test_migration_host_list
    @capfile.load_recipes('./config/deploy.rb')
    assert_equal ['db_primary'], @capfile.migration_host_list, "migration_host_list should be ['db_primary']"
  end
  
  def test_simple_deploy_rb_file
    @capfile.load_recipes('./config/simple_deploy.rb')
    assert_equal ['app_server'], @capfile.role_to_host_list(:app), "app server should be ['app_server']"
    assert_equal ['app_server'], @capfile.role_to_host_list(:db), "db server should be ['app_server']"
    assert_equal ['app_server'], @capfile.role_to_host_list(:web), "web server should be ['app_server']"
    assert_equal ['app_server'], @capfile.migration_host_list, "migration host server should be ['app_server']"
  end
end