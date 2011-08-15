$:.unshift File.expand_path('../lib', __FILE__)

require 'tdd_deploy/tdd_deploy_server'

run TddDeploy::Server.new
