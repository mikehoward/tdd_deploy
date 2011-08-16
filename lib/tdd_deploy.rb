$:.unshift File.expand_path('..', __FILE__)

require 'tdd_deploy/base'
require 'tdd_deploy/assertions'
require 'tdd_deploy/deploy_test_methods'
require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/version'

if defined? Rails
  require 'tdd_deploy/railengine'
end
