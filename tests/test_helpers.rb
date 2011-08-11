$:.unshift File.expand_path('../../lib', __FILE__)

# Add bundler setup to load path
require 'rubygems'
require 'bundler/setup'
# $:.each { |x| puts x }

require 'test/unit'
require 'net/ssh'
require 'capistrano'
require 'tdd_deploy'

class HostTestCase < Test::Unit::TestCase

  include TddDeploy

  def setup
    self.reset_env
    # if defined? ENV['HOSTS']
    #   self.hosts = ENV['HOSTS']
    # else
    #   require 'capistrano'
    #   c = Capistrano::Configuration.new
    #   c.load 'Capfile'
    #   self.hosts = c.roles[:hosts].map { |x| x.to_s }
    # end
  end

end


class SiteTestCase < HostTestCase
  def setup
    super
  end
end
