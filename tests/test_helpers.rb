$:.unshift File.expand_path('../../lib', __FILE__)

# Add bundler setup to load path
require 'rubygems'
require 'bundler/setup'
# $:.each { |x| puts x }

require 'test/unit'
require 'net/ssh'
require 'capistrano'
