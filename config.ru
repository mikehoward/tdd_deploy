$:.unshift File.expand_path('../lib', __FILE__)

require 'rack'
require 'tdd_deploy/server'

Rack::Server.start :Port => 9292, :app => TddDeploy::Server.new
