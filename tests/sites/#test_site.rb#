$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib/hosts', __FILE__)
$:.unshift File.expand_path('../lib/sites', __FILE__)

require 'test/unit'
require 'net/ssh'
require 'capistrano'
require 'test_host'

class SiteTestCase < HostTestCase
  attr_accessor :site, :site_user

  def setup
    super
    @site = ENV['SITE'] ? ENV['SITE'] : 'site'
    @site_user = ENV['SITE_USER'] ? ENV['SITE_USER'] : 'site'
    @site_base_port = ENV['SITE_BASE_PORT'] ? ENV['SITE_BASE_PORT'] : 8000
    @site_num_servers = ENV['SITE_NUM_SERVERS'] ? ENV['SITE_NUM_SERVERS'] : 3
  end
end
