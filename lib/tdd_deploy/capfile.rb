require 'capistrano/configuration'

module TddDeploy
  # == TddDeploy::Capfile - interface to capistrano capfile
  #
  # uses Capistrano to parse recipe file(s) and provides convenient access to server
  # definitions
  class Capfile
    # creates a Capfile::Configuration object to use, but does not read any Capistrano Recipe files
    def initialize
      @capfile_config = Capistrano::Configuration.new
    end

    # returns the Capistrano::Configuration::Roles object
    def roles
      @capfile_config.roles
    end

    # returns list of host strings defined for specified 'role'
    def role_to_host_list role
      servers(role).map { |srv| srv.to_s }
    end
    
    # returns list of host strings which are in the 'db' role and for which 'primary' is true
    def migration_host_list
      servers(:db).select { |srv| srv.options[:primary] == true }.map { |x| x.to_s }
    end
    
    # returns the array of Capistrano::ServerDefinition objects defined for 'role'
    def servers role
      @capfile_config.roles[role].servers
    end

    # loads the specified recipie file. Defaults to './config/deploy.rb' which is standard
    # for rails apps. May be called multiple times
    def load_recipes(path = './config/deploy.rb')
      @capfile_config.load path
    rescue LoadError => e
      msg = "Unable to load capistrano config file: #{path} - #{e}"
      raise LoadError.new msg
    end

  end
end