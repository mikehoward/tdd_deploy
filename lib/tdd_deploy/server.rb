#!/usr/bin/env ruby
$:.unshift File.expand_path('../lib', __FILE__)

require 'uri'
require 'tdd_deploy'

module TddDeploy
  class Server < TddDeploy::Base
    LIB_DIR = File.expand_path('../..', __FILE__)
    HOST_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'host_tests')
    SITE_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'site_tests')
    LOCAL_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'local_tests')

    attr_accessor :test_classes
  
    def initialize *args
      @already_defined = TddDeploy.constants
      super
    end

    def load_all_tests
      if TddDeploy::Base.children == [self.class]
        [TddDeploy::Server::HOST_TESTS_DIR, TddDeploy::Server::SITE_TESTS_DIR,
            TddDeploy::Server::LOCAL_TESTS_DIR].each do |dir|
          if File.exists?(dir)
            puts "gathering tests from #{dir}"
            Dir.new(dir).each do |fname|
              require File.join(dir, fname) unless fname[0] == '.'
            end
          else
            puts "skipping #{dir} - no such directory"
          end
        end
      end

      self.test_classes = TddDeploy::Base.children - [self.class]

      @test_classes_hash = {}
      self.test_classes.each do |klass|
        @test_classes_hash[klass.to_s] = klass
      end
    end
    
    def run_all_tests(test_group = nil)
      load_all_tests
      
      reset_tests

      test_classes = if test_group && defined?(@test_classes_hash)
        failed_test_keys = test_group.split(',')
        @test_classes_hash.select { |k, v| failed_test_keys.include? k }.values
      else
        self.test_classes
      end

      ret = true
      test_classes.each do |klass|
        obj = klass.new
        # puts "#{klass}.instance_methods: #{klass.instance_methods(false)}"
        klass.instance_methods(false).each do |func|
          ret &= obj.send func.to_sym
        end
      end
      ret
    end
    
    def parse_query_string(query_string)
      Hash[query_string.split('&').map { |tmp| key,value = tmp.split('='); [key, URI.decode(value)] }]
    end

    def call(env)
      query_hash = parse_query_string(env['QUERY_STRING'])
      run_all_tests query_hash['failed-tests']
      query_string = "failed-tests=" + URI.escape(@test_classes_hash.keys.join(','))
      body = ["<h1>TDD Test Results:</h1>",
        "<p><a href=/>Re-Run All Tests</a> <a href=/?#{query_string}>Re-Run Failed Tests</a></p>",
        self.test_results,
        "#{env.inspect}"
        ]
      return [200, {'Content-Length' => body.join('').length.to_s, 'Content-Type' => 'text/html'}, body]
    end
  end
end

