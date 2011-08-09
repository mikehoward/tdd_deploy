require 'active_support/concern'

module TddDeploy

    # == module TddDeploy::Environ
    #
    # provides management for host provisioning and deployment variables - aka 'the environment'.
    # The 'enviornment' - as used here - is not the Ruby ENV hash
    #
    # Note: this module uses the ActiveSupport::Concern module from Rails 3.[01] to manage
    # inclusion of class and instance methods. For details of concern, read the comments
    # in the module.
    #
    # three types of variables are supported
    #  :int - which are integers
    #  :string - which are strings
    #  :list - which are input as comma separated strings [the actual separator is /[\s,]+/ ]
    #    which are used internally as arrays of strings. So, to set a :list variable you
    #    write 'foo = bar,baz,boop', and when you use it you get back ['bar', 'baz', 'boop']
    #    (this inanity was done so we could save the environment as a simple ascii file)
    #
    # Environment variables:
    #
    # === Integer variables
    # * 'ssh_timeout' - timeout in seconds used to terminate remote commands fired off by ssh
    # * 'site_base_port' - Base port for site servers. For example, if a pack of mongrels or thin
    # servers provide the rails end of the web site, they listen on 'site_base_port', +1, etd
    # * 'site_num_servers' - number of mongrels or thins to spin up
    #
    # === String variables
    # * 'host_admin' - user name used on remote hosts. Should not be root, but should be in /etc/sudoers
    # * 'local_admin' - user name of on local hosts which can ssh into remote hosts via public key authentication
    # * 'local_admin_email' - email of local admin who should receive monitoring emails
    # * 'site' - name of site This should satisfy /[a-z][a-z0-9_]*.
    # * 'site_user' - name of site user. TddDeploy assumes that each site will have a unique user on the remote host.
    # this makes it easy to tell nginx and monit where to find configuration files for each site [both
    # know how to included globbed paths]
    #
    # === List Variables
    # * 'hosts' - list of all hosts - defaults to balance_hosts + db_hosts + web_hosts
    # * 'balance_hosts' - load balancing servers [may be empty, in which case 'hosts' is used]
    # * 'db_hosts' - hosts which run the database server [may be empty, in which case 'hosts' is used]
    # * 'web_hosts' - hosts which run the web server [may be empty, in which case 'hosts' is used]
    
  module Environ
    extend ActiveSupport::Concern
    
    ENV_FNAME = 'site_host_setup.env'

    module ClassMethods
      attr_accessor :env_types, :env_defaults, :env_hash
    
      # set up all the standard accessors

      # reset_env(value_hash {}) - convenience method which sets values of the environment
      # hash using a hash rather than one-at-a-time
      def reset_env(value_hash = {})
        @env_hash ||= {}
        value_hash.each do |k, v|
          k = k.to_s
          case self.env_types[k]
          when :int then @env_hash[k] = v.to_i
          when :string then @env_hash[k] = v.to_s
          when :list then @env_hash[k] = v.to_s.split(/[\s,]+/)
          else
            raise ArgumentError.new("#{self}#reset_env(): Illegal environment key: #{k}")
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

      # saves the current environment in the current working directory in the file
      # 'site_host_setup.env' [aka TddDeploy::Environ::ENV_FNAME]
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
    end
    
    # (dynamically) supplies accessors for each TddDeploy environment variable.
    # also provides access to TddDeploy::Environ class methods as instance methods.
    module InstanceMethods
      # returns the environment hash
      def env_hash
        self.class.env_hash
      end
      
      # an instance method which actually calls self.class.reset_env on the supplied hash.
      # raises ArgumentError if value not a Hash or a supplied key is incorrect
      def env_hash=(value)
        raise ArgumentError.new("env_hash must be a Hash") unless value.is_a? Hash
        self.class.reset_env(value)
      end

      # drags in all class methods as instance methods which delegate to corresponding class methods
      def method_missing *args
        method = args.shift
        if TddDeploy::Environ::ClassMethods.instance_methods(false).include? method.to_sym
          self.class.send method.to_sym, *args
        else
          args.unshift method
          super
        end
      end
    end
  
  included do
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
      def #{k}
        self.env_hash['#{k}']
      end
      EOF
      case env_types[k]
      when :int
        tmp +=<<-EOF
        def #{k}=(v)
          self.env_hash['#{k}'] = v.to_i
        end
        EOF
      when :string
        tmp +=<<-EOF
        def #{k}=(v)
          self.env_hash['#{k}'] = v.to_s
        end
        EOF
      when :list
        tmp +=<<-EOF
        def #{k}=(v)
          self.env_hash['#{k}'] = v.to_s.split(/[\s,]+/)
        end
        EOF
      end
    end

    class_eval tmp

    read_env || reset_env(self.env_defaults)
  end
  end
end