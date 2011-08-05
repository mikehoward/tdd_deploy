$:.unshift File.expand_path('../../lib', __FILE__)
# $:.unshift File.expand_path('../lib/hosts', __FILE__)
# $:.unshift File.expand_path('../lib/sites', __FILE__)
puts $:[0]

require 'test/unit'
require 'net/ssh'
require 'capistrano'
require 'tdd_deploy/run_methods'

class HostTestCase < Test::Unit::TestCase

  include TddDeploy::RunMethods

  def setup
    # see HostSetup.md/html for definitions of ADMIN & LOCAL_ADMIN
    @host_admin = ENV['HOST_ADMIN'] ? ENV['HOST_ADMIN'] : 'host_admin'
    @local_admin = ENV['LOCAL_ADMIN'] ? ENV['LOCAL_ADMIN'] : 'local_admin'
    @local_admin_email = ENV['LOCAL_ADMIN_EMAIL'] ? ENV['LOCAL_ADMIN_EMAIL'] : 'local_admin@example.com'
    if ENV['HOSTS']
      @hosts = ENV['HOSTS'].split
    else
      require 'capistrano'
      c = Capistrano::Configuration.new
      c.load 'Capfile'
      @hosts = c.roles[:hosts].map { |x| x.to_s }
    end
  end

end


class SiteTestCase < HostTestCase
  attr_accessor :site, :site_user, :site_base_port, :site_num_servers

  def setup
    super
    @site = ENV['SITE'] ? ENV['SITE'] : 'site'
    @site_user = ENV['SITE_USER'] ? ENV['SITE_USER'] : 'site'
    @site_base_port = ENV['SITE_BASE_PORT'] ? ENV['SITE_BASE_PORT'].to_i : 8000
    @site_num_servers = ENV['SITE_NUM_SERVERS'] ? ENV['SITE_NUM_SERVERS'].to_i : 3
  end
end
