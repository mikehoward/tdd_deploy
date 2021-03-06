require 'tdd_deploy/capfile'

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
    # All environment variables can be read or set via accessors - which are created
    # dynamically. They do _not_ show up in the Yard doc.
    #
    # === Integer variables
    # * 'ssh_timeout' - timeout in seconds used to terminate remote commands fired off by ssh
    # * 'site_base_port' - Base port for site servers. For example, if a pack of mongrels or thin
    #servers provide the rails end of the web site, they listen on 'site_base_port', +1, etd
    # * 'site_num_servers' - number of mongrels or thins to spin up
    #
    # === String variables
    # * 'host_admin' - user name used on remote hosts. Should not be root, but should be in /etc/sudoers
    # * 'local_admin' - user name of on local hosts which can ssh into remote hosts via public key authentication
    # * 'local_admin_email' - email of local admin who should receive monitoring emails
    # * 'site' - name of site This should satisfy /[a-z][a-z0-9_]*.
    # * 'site_app_root' - the absolute path to DocumentRoot for the site
    # * 'site_doc_root' - the absolute path to DocumentRoot for the site
    # * 'site_special_dir' - absolute path to site special directory - for system configuration fragments, commands, etc
    # * 'site_url' - the url for the site (w/o scheme - as in 'www.foo.com')
    # * 'site_aliases' - aliases for the site. The delimiters will depend on your web server
    # * 'site_user' - name of site user. TddDeploy assumes that each site will have a unique user on the remote host.
    # this makes it easy to tell nginx and monit where to find configuration files for each site [both
    # know how to included globbed paths]
    #
    # === List Variables
    # * 'app_hosts' - hosts running a ruby app which must have a ruby available and will be served
    #via a reverse proxy
    # * 'balance_hosts' - load balancing servers [may be empty, in which case 'hosts' is used]
    # * 'db_hosts' - hosts which run the database server [may be empty, in which case 'hosts' is used]
    # * 'web_hosts' - hosts which run the web server [may be empty, in which case 'hosts' is used]
    # * 'capfile_paths' - relative paths to capistrano recipe files. Defaults to './config/deploy.rb'
    #
    # === Pseudo Variables
    # * 'hosts' - list of all hosts - always returns app_hosts + balance_hosts + db_hosts + web_hosts.
    # may be assigned to if all three host lists are identical, otherwise raises an exception.
    #'tdd_deploy_context' hides it from view unless it can be assigned
    #
    # === Capfile Variables - Read Only
    # * 'app' - list of all hosts in the :app role of the Capistrano recipes
    # * 'db' - list of all hosts in the :db role of the Capistrano recipes
    # * 'migration_hosts' - list of all hosts in the :db role with option :primary => true
    #of the Capistrano recipes
    # * 'web' - list of all hosts in the :web role of the Capistrano recipes
    
    
  module Environ
    
    # == DataCache
    #
    # DataCache is a hack to provide a single shared data store for all classes which
    # include TddDeploy::Environ
    class DataCache
      class << self
        attr_accessor :env_hash, :env_types, :env_desc, :env_defaults, :capfile
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
      raise ::ArgumentError.new("env_hash=(): arg must be a hash") unless hash.is_a? Hash
      if !(tmp = hash.keys - DataCache.env_types.keys).empty?
        raise ::ArgumentError.new("env_hash=(): Illegal Keys in value: #{tmp.join(',')}")
      elsif !(tmp = DataCache.env_types.keys - hash.keys).empty?
        raise ::ArgumentError.new("env_hash=(): Missing Keys in value: #{tmp.join(',')}")
      else
        DataCache.env_hash = hash
      end
    end

    def capfile
      raise ::RuntimeError.new('Attempt to access capfile data w/o capfile_paths defined') unless DataCache.env_hash['capfile_paths']
      unless DataCache.capfile
        DataCache.capfile = TddDeploy::Capfile.new
        DataCache.env_hash['capfile_paths'].each do |path|
          DataCache.capfile.load_recipes path
        end
      end
      DataCache.capfile
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
      'site_aliases' => :string,
      'site_app_root' => :string,
      'site_doc_root' => :string,
      'site_special_dir' => :string,
      'site_user' => :string,

      'app_hosts' => :list,
      'balance_hosts' => :list,
      'capfile_paths' => :list,
      'db_hosts' => :list,
      'web_hosts' => :list,
      
      'hosts' => :pseudo,
      
      'app' => :capfile,
      'db' => :capfile,
      'migration_hosts'  => :capfile,
      'web' => :capfile,
    }

    DataCache.env_desc = {
      'ssh_timeout' => "ssh activity timeout in seconds",
      'site_base_port' => "the lowest port number used by your mongrel or thin cluster",
      'site_num_servers' => "number of mongrel or thin servers in your cluster",

      'host_admin' => "userid of the non-root administrator on all your remote hosts",
      'local_admin' => "userid on your local host which can ssh into all hosts as host_admin, root, and site_user",
      'local_admin_email' => "email address of the recipient of montoring email - currently put in monitrc fragments",

      'site' => 'name of site - will be the name of the deployment directory - as in /home/user/site/',
      'site_url' => 'the site url - www.foo.com',
      'site_aliases' => 'all the site aliases we need to put in nginx/apache configuration fragments',
      'site_app_root' => 'this is the root of the current app. probably /home/site_user/site/current',
      'site_doc_root' => 'this is DocumentRoot for the site. probably /home/site_user/site/current/public',
      'site_special_dir' => 'directory for monitrc, nginx config fragments, monit commands, etc',
      'site_user' => 'userid that the app lives in. This need not be host_admin. It\' separate so multiple sites can live on the same host',

      'app_hosts' => 'list of hosts the app will be installed on. Must have app stuff, like rvm, ruby, bundler, etc',
      'balance_hosts' => 'list of hosts running load balancers',
      'capfile_paths' => 'list of paths to Capistrano Capfile or ./config/deploy.rb or wherever you recipes are. Only used to get definitions of Capistrano roles.',
      'db_hosts' => 'list of hosts running database servers',
      'web_hosts' => 'list of hosts running real web servers - Apache or Nginx or ...',
      
      'hosts' => 'unqualified sum of app_hosts, balance_hosts, db_hosts, and web_hosts',
      
      'app' => 'list of servers in the Capistrano :app role',
      'db' => 'list of servers in the Capistrano :db role',
      'migration_hosts'  => 'list of servers in the Capistrano :db role with :primary => true',
      'web' => 'list of servers in the Capistrano :web role',
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
      'site_aliases' => '',
      'site_app_root' => '/home/site_user/site/current',
      'site_doc_root' => '/home/site_user/site/current/public',   # default for Capistrano
      'site_special_dir' => '/home/site_user/site_special',
      'site_user' => "site_user",

      'capfile_paths' => './config/deploy.rb',

      # 'hosts' => "bar,foo",
      'app_hosts' => 'arch',
      'balance_hosts' => '',
      'db_hosts' => 'arch',
      'web_hosts' => 'arch',
    }
    
    # Hash mapping environment variable to type
    def env_types
      DataCache.env_types
    end

    # Hash of default values - which are hokey
    def env_defaults
      DataCache.env_defaults
    end
    
    def env_desc
      DataCache.env_desc
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
        when :capfile then next
        when :pseudo then
          if k == 'hosts'
            if (tmp = DataCache.env_hash['web_hosts']) == DataCache.env_hash['db_hosts'] \
                &&  [] == DataCache.env_hash['balance_hosts'] \
                &&  tmp == DataCache.env_hash['app_hosts']
              DataCache.env_hash['web_hosts'] =
                DataCache.env_hash['db_hosts'] =
                  DataCache.env_hash['app_hosts'] = self.str_to_list(v)
              DataCache.env_hash['balance_hosts'] = []
            else
              raise ::RuntimeError.new("#{self}#reset_env(): Cannot assign value to 'hosts' if web_hosts &/or db_hosts already set.\n web_hosts: #{DataCache.env_hash['web_hosts']}\n db_hosts: #{DataCache.env_hash['db_hosts']}")
              # raise RuntimeError.new("Cannot change hosts key if web_hosts != db_hosts")
            end
          else
            next
          end
        else
          raise ::ArgumentError.new("#{self}#reset_env(): Illegal environment key: #{k}")
        end
      end
    end
    
    # clears the environment hash. Really - it's useless until re-initialized
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
                    raise ::ArugmentError.new("TddDeploy::Environ#read_env: Error in #{TddDeploy::Error::ENV_FNAME}: #{line_no}: Illegal Key: #{key}")
                  end
                else
                  raise ::ArugmentError.new("TddDeploy::Environ#read_env: Error in #{TddDeploy::Error::ENV_FNAME}: #{line_no}: Unmatched Line: #{line}}")
                end
              end
            ensure
              f.close
            end
            # add any missing env keys
            (self.env_types.keys - self.env_hash.keys).each do |key|
              case self.env_types[key]
              when :pseudo then next
              when :capfile then next
              when :list
                self.env_hash[key] = str_to_list(self.env_defaults[key])
              else
                self.env_hash[key] = self.env_defaults[key]
              end
            end
            return self.env_hash
          else
            raise ::RuntimeError.new("Unable to open #{path} for reading")
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

    # bursts comma/space separated string into a sorted, unique array
    def str_to_list str
      case
      when str.is_a?(String) then str.split(/[\s,]+/).uniq.sort
      when str.is_a?(Array) then str.uniq.sort
      else
        raise ::ArgumentError.new("str_to_list: #{str}")
      end
    end
    
    # packs an array into a comma separated string
    def list_to_str key
      tmp = self.env_hash[key]
      tmp.is_a?(Array) ? tmp.join(',') : tmp.to_s
    end

    public
    # saves the current environment in the current working directory in the file
    # 'site_host_setup.env' [aka TddDeploy::Environ::ENV_FNAME]
    def save_env
      f = File.new(TddDeploy::Environ::ENV_FNAME, "w")
      self.env_types.keys.sort.each do |k|
        v = self.env_hash[k] || ''
        case self.env_types[k]
        when :int then f.write "#{k}=#{v}\n"
        when :string then f.write "#{k}=#{v}\n"
        when :list then
          f.write "#{k}=#{self.list_to_str(k)}\n" unless k == 'hosts'
        when :pseudo then next
        when :capfile then next
        else
          raise ::RuntimeError.new("unknown key: #{k}")
        end
      end
      f.close
    end
    
    # create accessors for all keys in env_types which are not :pseudo variables
    tmp = ''
    DataCache.env_types.each do |k, t|
      next if t == :pseudo
      
      tmp +=<<-EOF
      def #{k}
        if '#{k}' == 'capfile_paths' && (self.env_hash['capfile_paths'].nil? || self.env_hash['capfile_paths'] == [])
          DataCache.capfile = nil
          self.env_hash['capfile_paths'] = self.str_to_list self.env_defaults['capfile_paths']
        else
          self.env_hash['#{k}']
        end
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
         if '#{k}' == 'capfile_paths'
           DataCache.capfile = nil
           self.env_hash['capfile_paths'] = self.env_defaults['capfile_paths'] if v.nil?
         end
        end
        EOF
      when :capfile
        tmp +=<<-EOF
        def #{k}
          self.capfile.role_to_host_list :#{k}
        end
        EOF
      else
        raise Exception.new("Internal Error: key #{k} has invalid type: #{t}")
      end
    end
    
    class_eval tmp

    # accessors for all defined env variables
    def hosts
      (self.web_hosts.to_a + self.db_hosts.to_a + self.balance_hosts.to_a + self.app_hosts.to_a).uniq.sort
    end
    
    def hosts=(list)
      if (self.web_hosts.nil? && self.db_hosts.nil?) || self.web_hosts == self.db_hosts
        self.web_hosts =
          self.db_hosts =
            self.app_hosts = self.str_to_list(list)
        self.balance_hosts = []
      else
        raise ::RuntimeError.new("Cannot assign value to 'hosts' if web_hosts &/or db_hosts already set.\n web_hosts: #{self.web_hosts}\n db_hosts: #{self.db_hosts}")
      end
    end
    
    def migration_hosts
      self.capfile.migration_host_list
    end
    
    # takes the name of a list (as a string or symbol), a single string, or an array of host names.
    # If it's an array, then returns uniq-ified array of strings [to handle the uniion of lists]
    def rationalize_host_list(host_list_or_list_name)
      if host_list_or_list_name.is_a? String
        return self.respond_to?(host_list_or_list_name.to_sym) ? self.send(host_list_or_list_name.to_sym) :
          [host_list_or_list_name]
      elsif host_list_or_list_name.is_a? Symbol
        return self.respond_to?(host_list_or_list_name) ? self.send(host_list_or_list_name) :
              [host_list_or_list_name.to_s]
      elsif host_list_or_list_name.is_a? Array
        return host_list_or_list_name.map { |host| host.to_s }.uniq
      else
        raise ArgumentError.new("rationalize_host_list(#{host_list_or_list_name.inspect}) is invalid")
      end
    end
  end
end