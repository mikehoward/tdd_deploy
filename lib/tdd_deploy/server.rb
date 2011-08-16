#!/usr/bin/env ruby
$:.unshift File.expand_path('../lib', __FILE__)

require 'tdd_deploy'

module TddDeploy
  class Server < TddDeploy::Base
    LIB_DIR = File.expand_path('../..', __FILE__)
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
        # puts "#{klass}.instance_methods: #{klass.instance_methods(false)}"
        klass.instance_methods(false).each do |func|
          ret &= obj.send func.to_sym
        end
      end
      ret
    end
    
    def call(env)
      run_all_tests
      body = ["<h1>TDD Test Results:</h1>", self.test_results]
      return [200, {'Content-Length' => body.join('').length.to_s, 'Content-Type' => 'text/html'}, body]
    end
  end
end

