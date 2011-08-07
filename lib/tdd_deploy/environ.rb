require 'active_support/concern'

module TddDeploy
  module Environ
    ENV_FNAME = 'site_host_setup.env'
    #   require 'active_support/concern'
    #
    #   module Foo
    #     extend ActiveSupport::Concern
    #     included do
    #       class_eval do
    #         def self.method_injected_by_foo
    #           ...
    #         end
    #       end
    #     end
    #   end
    #
    #   module Bar
    #     extend ActiveSupport::Concern
    #     include Foo
    #
    #     included do
    #       self.method_injected_by_foo
    #     end
    #   end
    #
    #   class Host
    #     include Bar # works, Bar takes care now of its dependencies
    #   end
    
    extend ActiveSupport::Concern
    

    # == TddDeploy
    #
    # TddDeploy is a module which creates a top level name space, defines required accessors
    # and drags in TddDeploy::RunMethods and TddDeploy::DeployTestMethods
    #
    # Use it by defining a class and then include TddDeploy to get all the goodies
    #
    # set up all the standard accessors
    module ClassMethods
      attr_accessor :env_types, :env_defaults, :env_hash


puts "self: #{self}"
puts "self.public_methods: #{self.public_methods(false).sort}"

      # env_types =  env_types
      # env_defaults = env_defaults
      # env_hash = {}
      # 
      def reset_env(value_hash)
        @env_hash ||= {}
        value_hash.each do |k, v|
          case self.env_types[k]
          when :int then @env_hash[k] = v.to_i
          when :string then @env_hash[k] = v.to_s
          when :list then @env_hash[k] = v.to_s.split(/[\s,]+/)
          else
            raise "#{self}#reset_env(): Illegal environment key: #{k}"
          end
        end
      end

      # reads the environment from TddDeploy::Environ::ENV_FNAME (site_host_setup.env) if the file exists
      # someplace between the current directory and the root of the filesystem
      def read_env
        dir_path = Dir.pwd
        loop do
          path = File.join dir_path, TddDeploy::Environ::ENV_FNAME
          if File.exists? TddDeploy::Environ::ENV_FNAME
            File.new(path, 'r').each do |line|
              if line =~ /^\s*(\w+)\s*=\s*(\d+)\s*$/
                self.env_hash[$1.downcase] = $2.to_i
              elsif line =~ /^\s*(\w+)\s*=\s*(.*?)\s*$/
                self.env_hash[$1.downcase] = $2.to_s
              else
                puts "unmatched line: #{line}"
              end
            end
            return self.env_hash
          elsif dir_path.length <= 1
            # reached root level, so initialize to defaults and exit
            reset_env self.env_defaults
            return @env_hash
          else
            # move to parent directory
            dir_path = File.expand_path('..', dir_path)
          end
        end
        nil
      end

      # saves the current environment in the current working directory
      def save_env
        f = File.new(TddDeploy::Environ::ENV_FNAME, "w")
        self.env_hash.each do |k, v|
          case self.env_types[k]
          when :int then f.write "#{k}=#{v}\n"
          when :string then f.write "#{k}=#{v}\n"
          when :list then f.write "#{k}=#{v.join(',')}\n"
          end
        end
        f.close
      end
    end  # end of ClassMethods

    module InstanceMethods
      def method_missing(*args)
        method = args.shift
        return self.class.send method.to_sym, *args if self.class.respond_to? method.to_sym
        args.unshift method
        super
      end
    end

    included do
puts "#{File.basename(__FILE__)}: #{__LINE__}"
puts "self: #{self}"
puts "self.class_methods: #{self.public_methods(false).sort}"
      self.env_types = {
        'ssh_timeout' => :int,
        'site_base_port' => :int,
        'site_num_servers' => :int,

        'host_admin' => :string,
        'local_admin' => :string,
        'local_admin_email' => :string,

        'site' => :string,
        'site_user' => :string,

        'hosts' => :list,
        'balance_hosts' => :list,
        'db_hosts' => :list,
        'web_hosts' => :list,
      }
      self.env_defaults = {
        'ssh_timeout' => 5,
        'site_base_port' => 8000,
        'site_num_servers' => 3,

        'host_admin' => "host_admin",
        'local_admin' => "local_admin",
        'local_admin_email' => "local_admin@bogus.tld",

        'site' => "site",
        'site_user' => "site_user",

        'hosts' => "foo,bar",
        'balance_hosts' => '',
        'db_hosts' => '',
        'web_hosts' => '',
      }
      self.env_hash = {}

      # create accessors
      tmp = ''
      env_types.each do |k, t|
        tmp +=<<-EOF
        def self.#{k}
          self.env_hash['#{k}']
        end
        EOF
        case env_types[k]
        when :int
          tmp +=<<-EOF
          def self.#{k}=(v)
            self.env_hash['#{k}'] = v.to_i
          end
          EOF
        when :string
          tmp +=<<-EOF
          def self.#{k}=(v)
            self.env_hash['#{k}'] = v.to_s
          end
          EOF
        when :list
          tmp +=<<-EOF
          def self.#{k}=(v)
            self.env_hash['#{k}'] = v.to_s.split(/[\s,]+/)
          end
          EOF
        end
      end

      class_eval tmp
puts "self.class_methods: #{self.public_methods(false).sort}"
puts "self.instance_methods: #{self.instance_methods(false).sort}"

      self.read_env
    end
  end
end