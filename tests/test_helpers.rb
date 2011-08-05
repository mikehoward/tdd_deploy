$:.unshift File.expand_path('../../lib', __FILE__)
# $:.unshift File.expand_path('../lib/hosts', __FILE__)
# $:.unshift File.expand_path('../lib/sites', __FILE__)
puts $:[0]

require 'test/unit'
require 'net/ssh'
require 'capistrano'
require 'tdd_deploy'

class HostTestCase < Test::Unit::TestCase

  include TddDeploy

  def setup
    # see HostSetup.md/html for definitions of ADMIN & LOCAL_ADMIN
    ['HOST_ADMIN', 'LOCAL_ADMIN', 'LOCAL_ADMIN_EMAIL'].each do |key|
      self.send "#{key.downcase}=".to_sym, ENV[key] if defined? ENV[key]
    end
    if defined? ENV['HOSTS']
      self.hosts = ENV['HOSTS']
    else
      require 'capistrano'
      c = Capistrano::Configuration.new
      c.load 'Capfile'
      self.hosts = c.roles[:hosts].map { |x| x.to_s }
    end
  end

end


class SiteTestCase < HostTestCase
  def setup
    super
    ['SITE', 'SITE_USER', 'SITE_BASE_PORT', 'SITE_NUM_SERVERS'].each do |key|
      self.send "#{key.downcase}=".to_sym, ENV[key] if defined? ENV[key]
    end
  end
end
