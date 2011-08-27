#!/usr/bin/env ruby
$:.unshift File.expand_path('../lib', __FILE__)

require 'uri'
require 'tdd_deploy'
require 'tdd_deploy/test_base'

module TddDeploy
  # == TddDeploy::Server
  #
  # implements a simple 'rack' server. Methods are either used internally or called
  # from the web page during page reloads.
  #
  # It only displays one page - which is defined in the gem in
  # lib/tdd_deploy/server-templates/test_results.html.erb.
  class Server < TddDeploy::Base
    LIB_DIR = File.expand_path('../..', __FILE__)
    HOST_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'host_tests')
    SITE_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'site_tests')
    LOCAL_TESTS_DIR = File.join(Dir.pwd, 'lib', 'tdd_deploy', 'local_tests')
    TEMPLATE_PATH = File.join(LIB_DIR, 'tdd_deploy', 'server-templates', 'test_results.html.erb')

    attr_accessor :test_classes, :query_hash
  
    def initialize *args
      raise RuntimeError.new("No Environment File") unless File.exists? TddDeploy::Environ::ENV_FNAME
      super
      load_all_tests
      @request_count = 0
    end
    
    # failed_tests returns a unique, sorted list of strings. It just seemed easier to
    # do it in the accessors than take the chance of using push, pop, etc and mucking it
    # up - like I did before.
    def failed_tests
      @failed_tests ||= []
      raise RuntimeError.new("@failed_tests is not an Array: #{@failed_tests.inspect}") unless @failed_tests.is_a? Array
      @failed_tests = @failed_tests.map { |x| x.to_s }.uniq.sort
    end
    
    # failed_tests= does the right thing for all kinds of input variations.
    def failed_tests=(value)
      begin
        value = value.split(/[\s,]+/) if value.is_a? String
        value = [value] unless value.is_a? Array
      
        @failed_tests = @failed_tests.to_a unless @failed_tests.is_a? Array

        @failed_tests = (@failed_tests + value.map { |x| x.to_s }).uniq
      rescue
        @failed_tests = (@failed_tests.to_a.map { |x| x.to_s } + value.to_a.map { |x| x.to_s }).uniq.sort
      end
    end

    # rack interface. takes an env Hash and returns [code, headers, body]
    def call(env)
      self.query_hash = parse_query_string(env['QUERY_STRING'])

      if self.query_hash['run_configurator']
        require 'tdd_deploy/configurator'
        configurator = TddDeploy::Configurator.new
        configurator.make_configuration_files
      end

      load_all_tests
      
      if query_hash['failed-tests'] && @request_count > 0
        remove_failed_tests
        run_selected_tests(query_hash['failed-tests'])
      else
        run_all_tests
      end
      @request_count += 1
      
      query_string = new_query_string
      body = [
        render_results,
        # "#{env.inspect}"
        ]
      return [200, {'Content-Length' => body.join('').length.to_s, 'Content-Type' => 'text/html'}, body]
    end

    # loads all files in 'lib/tdd_deploy/host_tests | site_tests | local_tests.
    # both host_tests and site_tests are clobbered by the rake install task.
    # local_tests is safe.
    def load_all_tests
      # discard any already defined tests
      TddDeploy::TestBase.flush_children_methods
      
      # reload all tests
      [TddDeploy::Server::HOST_TESTS_DIR, TddDeploy::Server::SITE_TESTS_DIR,
          TddDeploy::Server::LOCAL_TESTS_DIR].each do |dir|
        if File.exists?(dir)
          # puts "gathering tests from #{dir}"
          Dir.new(dir).each do |fname|
            load File.join(dir, fname) if fname =~ /\.rb$/
          end
        else
          puts "skipping #{dir} - no such directory"
        end
      end

      self.test_classes = TddDeploy::TestBase.children

      @test_to_class_map = {}
      self.test_classes.each do |klass|
        klass.instance_methods(false).each do |func|
          @test_to_class_map[func.to_s] = klass
        end
      end
    end
    
    # Re-reads the environment and then runs all known tests.
    def run_all_tests
      read_env
      reset_tests

      ret = true
      self.failed_tests = []
      self.test_classes.each do |klass|
        ret &= run_all_tests_in_class(klass)
      end
      ret
    end
    
    # Re-reads the environment and then runs tests from 'test_list'
    def run_selected_tests(test_list)
      read_env
      ret = true
      test_list = test_list.split(/[\s,]+/) if test_list.is_a? String
      self.failed_tests -= test_list
      test_list.each do |test|
        ret &= run_a_test test
      end
      ret
    end

    private

    # used by 
    def run_all_tests_in_class klass
      read_env
      obj = klass.new
      ret = true
      # puts "#{klass}.instance_methods: #{klass.instance_methods(false)}"
      klass.instance_methods(false).each do |func|
        test_result = obj.send func.to_sym
        self.failed_tests.push(func) unless test_result
        ret &= test_result
      end
      ret
    end
    
    def run_a_test test
      return false unless (klass = @test_to_class_map[test])
      obj = klass.new
      test_result = obj.send test.to_sym
      self.failed_tests.push(test) unless test_result
      test_result
    end
    
    def parse_query_string(query_string)
      return '' unless query_string.is_a? String
      Hash[query_string.split('&').map { |tmp| key,value = tmp.split('='); value ? [key, URI.decode(value)] : [key, 'true']}]
    end
    
    def render_results
      f = File.new(TEMPLATE_PATH)
      template = ERB.new f.read, nil, '<>'
      f.close

      # add 'server_obj' so accessors are accessible from erb template
      server_obj = self
      template.result(binding)
    end
        
    def new_query_string
      "failed-tests=" + URI.escape(self.failed_tests.join(',')) unless @failed_tests.empty?
    end

  end
end

