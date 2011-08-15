#!/usr/bin/env ruby

require 'gserver'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'tdd_deploy'

module TddDeploy
  class Server < TddDeploy::Base
    LIB_DIR = File.expand_path('../../lib', __FILE__)
    HOST_TESTS_DIR = File.join('tdd_deploy', 'host_tests')
    SITE_TESTS_DIR = File.join('tdd_deploy', 'site_tests')

    attr_accessor :port, :test_classes
  
    def initialize *args
      @port = args.shift
      @already_defined = TddDeploy.constants
      super
    end

    def load_all_tests
      if TddDeploy::Base.children == [self.class]
        [TddDeploy::Server::HOST_TESTS_DIR, TddDeploy::Server::SITE_TESTS_DIR].each do |dir|
          Dir.new(File.join(TddDeploy::Server::LIB_DIR, dir)).each do |fname|
            require File.join(dir, fname) unless fname[0] == '.'
          end
        end
      end
      self.test_classes = TddDeploy::Base.children - [self.class]
    end
    
    def run_all_tests
      load_all_tests

      ret = true
      self.test_classes.each do |klass|
        obj = klass.new
        puts "#{klass}.instance_methods: #{klass.instance_methods(false)}"
        klass.instance_methods(false).each do |func|
          ret &= obj.send func.to_sym
        end
      end
      ret
    end
  end
end

class String
  def snake_to_camel
    raise "Can't camelize #{self}" if self[0] == '_' || self[-1] == '_'
    self.split('_').map { |word| word.capitalize }.join('')
  end

  def camel_to_snake
    str = ''
    self.split(/([A-Z])/).each do |chunk|
      if chunk =~ /[A-Z]/
        str += '_' unless str == ''
        str += chunk.downcase
      else
        str += chunk
      end
    end
    str
  end
end
