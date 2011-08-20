module TddDeploy

    # == module TddDeploy::Environ
    #
    # provides management for host provisioning and deployment variables - aka 'the environment'.
    # The 'enviornment' - as used here - is not the Ruby ENV hash
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
    
    # == DataCache
    #
    # DataCache is a hack to provide a single shared data store for all classes which
    # include TddDeploy::Environ
    class DataCache
      class << self
        attr_accessor :env_hash, :env_types, :env_defaults
      end
    end
    
    ENV_FNAME = 'site_host_setup.env'

    # set up all the standard accessors
    # lazy initialize DataCache.env_hash
    def env_hash
      read_env || reset_env unless defined?(DataCache.env_hash)
      DataCache.env_hash
    end
    
    def env_hash=(hash)
      raise ArgumentError.new("env_hash=(): arg must be a hash") unless hash.is_a? Hash
      if !(tmp = hash.keys - DataCache.env_types.keys).empty?
        raise ArgumentError.new("env_hash=(): Illegal Keys in value: #{tmp.join(',')}")
      elsif !(tmp = DataCache.env_types.keys - hash.keys).empty?
        raise ArgumentError.new("env_hash=(): Missing Keys in value: #{tmp.join(',')}")
      else
        DataCache.env_hash = hash
      end
    end
    
    DataCache.env_types = {
      'ssh_timeout' => :int,
      'site_base_port' => :int,
      'site_num_servers' => :int,

      'host_admin' => :string,
      'local_admin' => :string,
      'local_admin_email' => :string,

      'site' => :string,
      'site_url' => :string,
      'site_path' => :string,
      'site_user' => :string,

      # 'hosts' => :list,
      'balance_hosts' => :list,
      'db_hosts' => :list,
      'web_hosts' => :list,
    }
    
    DataCache.env_defaults ||= {
      'ssh_timeout' => 5,
      'site_base_port' => 8000,
      'site_num_servers' => 3,

      'host_admin' => "host_admin",
      'local_admin' => "local_admin",
      'local_admin_email' => "local_admin@bogus.tld",

      'site' => "site",
      'site_url' => 'www.site.com',                    # don't include the scheme
      'site_path' => '/home/site_user/site.d/current',   # default for Capistrano
      'site_user' => "site_user",

      # 'hosts' => "bar,foo",
      'balance_hosts' => 'arch',
      'db_hosts' => 'arch',
      'web_hosts' => 'arch',
    }
    
    def env_types
      DataCache.env_types
    end

    def env_defaults
      DataCache.env_defaults
    end

    # set_env(value_hash {}) - convenience method which sets values of the environment
    # hash using a hash rather than one-at-a-time
    def set_env(value_hash = {})
      DataCache.env_hash ||= {}
      value_hash.each do |k, v|
        k = k.to_s
        case self.env_types[k]
        when :int then DataCache.env_hash[k] = v.to_i
        when :string then DataCache.env_hash[k] = v.to_s
        when :list then DataCache.env_hash[k] = self.str_to_list(v)
        else
          if k == 'hosts'
            if DataCache.env_hash['web_hosts'] == DataCache.env_hash['db_hosts'] &&  DataCache.env_hash['web_hosts'] == DataCache.env_hash['balance_hosts']
              DataCache.env_hash['web_hosts'] =
                DataCache.env_hash['db_hosts'] =
                  DataCache.env_hash['balance_hosts'] = self.str_to_list(v)
            else
              raise RuntimeError.new("#{self}#reset_env(): Cannot assign value to 'hosts' if web_hosts &/or db_hosts already set.\n web_hosts: #{DataCache.env_hash['web_hosts']}\n db_hosts: #{DataCache.env_hash['db_hosts']}")
              # raise RuntimeError.new("Cannot change hosts key if web_hosts != db_hosts")
            end
          else
            raise ArgumentError.new("#{self}#reset_env(): Illegal environment key: #{k}")
          end
        end
      end
    end
    
    def clear_env
      DataCache.env_hash = {}
    end
    
    # reset_env resets env_hash to env_defaults
    def reset_env
      clear_env
      set_env self.env_defaults
    end

    # reads the environment from TddDeploy::Environ::ENV_FNAME (site_host_setup.env) if the file exists
    # someplace between the current directory and the root of the filesystem
    def read_env
      dir_path = Dir.pwd
      DataCache.env_hash ||= {}
      loop do
        path = File.join dir_path, TddDeploy::Environ::ENV_FNAME
        if File.exists? TddDeploy::Environ::ENV_FNAME
          line_no = 0
          if f = File.new(path, 'r')
            begin
              f.each do |line|
                line_no += 1
                if line =~ /^\s*(\w+)\s*=\s*(.*?)\s*$/
                  key = $1.downcase
                  if self.env_types.keys.include? key
                    self.send "#{key}=".to_sym, $2
                    # self.env_hash[key] = self.env_types[key] == :list ? self.str_to_list($2) : $2.to_s
                  else
                    raise ArugmentError.new("TddDeploy::Environ#read_env: Error in #{TddDeploy::Error::ENV_FNAME}: #{line_no}: Illegal Key: #{key}")
                  end
                else
                  raise ArugmentError.new("TddDeploy::Environ#read_env: Error in #{TddDeploy::Error::ENV_FNAME}: #{line_no}: Unmatched Line: #{line}}")
                end
              end
            ensure
              f.close
            end
            return self.env_hash
          else
            raise RuntimeError.new("Unable to open #{path} for reading")
          end
        elsif dir_path.length <= 1
          # reached root level, so initialize to defaults and exit
          return nil
        else
          # move to parent directory
          dir_path = File.expand_path('..', dir_path)
        end
      end
      nil
    end

    def str_to_list str
      case
      when str.is_a?(String) then str.split(/[\s,]+/).uniq.sort
      when str.is_a?(Array) then str.uniq.sort
      else
        raise ArgumentError.new("str_to_list: #{str}")
      end
    end
    
    def list_to_str key
      tmp = self.env_hash[key]
      tmp.is_a?(Array) ? tmp.join(',') : tmp.to_s
    end

    # saves the current environment in the current working directory in the file
    # 'site_host_setup.env' [aka TddDeploy::Environ::ENV_FNAME]
    def save_env
      f = File.new(TddDeploy::Environ::ENV_FNAME, "w")
      self.env_types.keys.each do |k|
        v = self.env_hash[k] || ''
        case self.env_types[k]
        when :int then f.write "#{k}=#{v}\n"
        when :string then f.write "#{k}=#{v}\n"
        when :list then
          f.write "#{k}=#{self.list_to_str(k)}\n" unless k == 'hosts'
        else
          raise RuntimeError("unknown key: #{k}")
        end
      end
      f.close
    end

    # accessors for all defined env variables
    def hosts
      (self.web_hosts.to_a + self.db_hosts.to_a + self.balance_hosts.to_a).uniq.sort
    end
    
    def hosts=(list)
      if (self.web_hosts.nil? && self.db_hosts.nil?) || self.web_hosts == self.db_hosts
        self.web_hosts =
          self.db_hosts =
            self.balance_hosts = self.str_to_list(list)
      else
        raise RuntimeError.new("Cannot assign value to 'hosts' if web_hosts &/or db_hosts already set.\n web_hosts: #{self.web_hosts}\n db_hosts: #{self.db_hosts}")
      end
    end

    # create accessors for all keys in env_types
    tmp = ''
    DataCache.env_types.each do |k, t|
      tmp +=<<-EOF
      def #{k}
        self.env_hash['#{k}']
      end
      EOF
      case DataCache.env_types[k]
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
         self.env_hash['#{k}'] = self.str_to_list(v)
        end
        EOF
      end
    end

    class_eval tmp
  end
end