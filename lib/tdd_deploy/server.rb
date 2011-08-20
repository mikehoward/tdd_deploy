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
    TEMPLATE_PATH = File.join(LIB_DIR, 'tdd_deploy', 'server-templates', 'test_results.html.erb')

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
      @failed_tests = []
      test_classes.each do |klass|
        obj = klass.new
        # puts "#{klass}.instance_methods: #{klass.instance_methods(false)}"
        klass.instance_methods(false).each do |func|
          test_result = obj.send func.to_sym
          @failed_tests.push(func) unless test_result
          ret &= test_result
        end
      end
      ret
    end
    
    def parse_query_string(query_string)
      return '' unless query_string.is_a? String
      Hash[query_string.split('&').map { |tmp| key,value = tmp.split('='); [key, URI.decode(value)] }]
    end
    
    def render_results
      f = File.new(TEMPLATE_PATH)
      template = ERB.new f.read, nil, '<>'
      f.close
      
      template.result(binding)
    end
    
    def new_query_string
      str = "failed-tests=" + URI.escape(@failed_tests.join(',')) unless @failed_tests.nil? || @failed_tests.empty?
    end

    def call(env)
      query_hash = parse_query_string(env['QUERY_STRING'])
      run_all_tests query_hash['failed-tests']
      query_string = new_query_string
      body = ["<h1>TDD Test Results:</h1>",
        "<p><a href=/>Re-Run All Tests</a> <a href=/?#{query_string}>Re-Run Failed Tests</a></p>",
        render_results,
        "#{env.inspect}"
        ]
      return [200, {'Content-Length' => body.join('').length.to_s, 'Content-Type' => 'text/html'}, body]
    end
  end
end

