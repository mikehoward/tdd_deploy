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
  
  env_init = {
      'ssh_timeout' => 5,
      'host_admin' => "'host_admin'",
      'hosts' => "''",
      'local_admin' => "'local_admin'",
      'local_admin_email' => "'local_admin@bogus.tld'",
  
      'site' => "'site'",
      'site_user' => "'site_user'",
      'site_base_port' => 8000,
      'site_num_servers' => 3,
    }

    def mod.env_hash
      @env_hash
    end

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
  
    def mod.save_env
      f = File.new(TddDeploy::ENV_FNAME, "w")
      @env_hash.each do |k, v|
        f.write "#{k}=#{v}\n"
      end
      f.close
    end

    mod.read_env env_init
    env_init.each do |k, v|
      tmp =<<-EOF
      def #{k}
        @#{k} ||= (self.class.env_hash['#{k}'] || #{v})
      end
      def #{k}=(val)
        @#{k} = self.class.env_hash['#{k}'] = val
      end
      EOF

      mod.class_eval tmp
    end
  end

  def save_env
    self.class.save_env
  end

  # include core methods
  include TddDeploy::RunMethods
  include TddDeploy::DeployTestMethods
end
