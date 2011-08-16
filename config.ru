$:.unshift File.expand_path('../lib', __FILE__)

require 'rack'
require 'tdd_deploy/tdd_deploy_server'

puts "File.expand_path('../lib', __FILE__): #{File.expand_path('../lib', __FILE__)}"
puts "Dir.pwd: #{Dir.pwd}"

Rack::Server.new
