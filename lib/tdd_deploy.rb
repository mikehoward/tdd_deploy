$:.unshift File.expand_path('..', __FILE__)

require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'

module TddDeploy
  ENV_FNAME = 'site_host_setup.env' unless defined? ENV_FNAME

  # == TddDeploy
  #
  # TddDeploy is a module which creates a top level name space, defines required accessors
  # and drags in TddDeploy::RunMethods and TddDeploy::DeployTestMethods
  #
  # Use it by defining a class and then include TddDeploy to get all the goodies
  #
  # set up all the standard accessors
  def self.included(mod)
  
  env_init_int_params = {
      'ssh_timeout' => 5,
      'site_base_port' => 8000,
      'site_num_servers' => 3,
    }
    env_init_str_params = {
      'host_admin' => "'host_admin'",
      'host_list' => "''",
      'local_admin' => "'local_admin'",
      'local_admin_email' => "'local_admin@bogus.tld'",

      'site' => "'site'",
      'site_user' => "'site_user'",
    }
    env_init_list_params = {
        'host_list' => "''",
    }
    env_init_merged = env_init_list_params.merge(env_init_str_params).merge(env_init_int_params)

    # returns the environment hash from the class
    def mod.env_hash
      @env_hash
    end

    # reads the environment from TddDeploy::ENV_FNAME (site_host_setup.env) if the file exists
    # someplace between the current directory and the root of the filesystem
    def mod.read_env(env_init = nil)
      dir_path = Dir.pwd
      @env_hash = env_init || {}
      loop do
        path = File.join dir_path, TddDeploy::ENV_FNAME
        if File.exists? TddDeploy::ENV_FNAME
          File.new(path, 'r').each do |line|
            if line =~ /^\s*(\w+)\s*=\s*(\d+)\s*$/
              @env_hash[$1.downcase] = $2.to_i
            elsif line =~ /^\s*(\w+)\s*=\s*((['"]).*\3)\s*$/
              @env_hash[$1.downcase] = $2.to_s
            else
              puts "unmatched line: #{line}"
            end
          end
          return @env_hash
        elsif dir_path.length <= 1
          break
        else
          dir_path = File.expand_path('..', dir_path)
        end
      end
      nil
    end
    
    def mod.reset_env
      puts env_init_merged
    end
  
    # saves the current environment in the current working directory
    def mod.save_env
      f = File.new(TddDeploy::ENV_FNAME, "w")
      @env_hash.each do |k, v|
        f.write "#{k}=#{v}\n"
      end
      f.close
    end

    mod.read_env env_init_merged
    env_init_merged.each do |k, v|
      tmp =<<-EOF
      def #{k}
        @#{k} ||= (self.class.env_hash['#{k}'] || #{v})
      end
      EOF
      mod.class_eval tmp
    end
    env_init_str_params.each do |k, v|
      tmp =<<-EOF
      def #{k}=(val)
        @#{k} = self.class.env_hash['#{k}'] = val.to_s
      end
      EOF
      mod.class_eval tmp
    end
    env_init_int_params.each do |k, v|
      tmp =<<-EOF
      def #{k}=(val)
        @#{k} = self.class.env_hash['#{k}'] = val.to_i
      end
      EOF
      mod.class_eval tmp
    end
    env_init_list_params.each do |k, v|
      tmp =<<-EOF
      def #{k}=(val)
        @#{k} = self.class.env_hash['#{k}'] = val.to_s.split(/[\s,]+/).join(',')
      end
      EOF
      mod.class_eval tmp
    end
  end

  # hosts is the host list
  def hosts
    @hosts ||= self.host_list.split(/[\s,]+/)
  end
  
  # hosts = array of hosts
  def hosts=(host_list)
    @host_list = host_list.join(',')
    @hosts = host_list
  end

  # instance method which calls self.class.save_env
  def save_env
    self.class.save_env
  end
  
  # instance method access to self.class.env_hash
  def env_hash
    self.class.env_hash
  end

  # include core methods
  include TddDeploy::RunMethods
  include TddDeploy::DeployTestMethods
end
