#! /usr/bin/env ruby
#  -*- ruby-mode -*-

require 'erb'
require 'tdd_deploy/base'

module TddDeploy
  # == TddDeployConfigurator
  #
  # TddDeployConfigurator is used to create site/host specific configuration files for
  # sites. The files are defined by templates in subdirectories of the 'site-erb' directory.
  # At present there are templates in 'site-erb/config' and 'site-erb/site'. Rendered files
  # are written to corresponding subdirectories of the app. For example, 'site-erb/config/foo.erb'
  # will produce the file 'app/config/foo'
  #
  # files dropped into 'app/site/' are assumed to be executable, so their permissions are
  # set to 0755
  class Configurator < TddDeploy::Base
    # install - reads all the templates in gem-home/site-erb, renders them using the
    #  current environment context, and writes the renderings to the appropriate
    #  files in app/sites and app/config
    def make_configuration_files
      # create local directory for output files
      tdd_deploy_configs = File.join Dir.pwd, 'tdd_deploy_configs'
      Dir.mkdir(tdd_deploy_configs) unless File.exists? tdd_deploy_configs

      ['balance_hosts', 'db_hosts', 'web_hosts'].each do |host_dir|
        host_path = File.join(tdd_deploy_configs, host_dir)
        Dir.mkdir(host_path) unless File.exists? host_path

        ['config', 'site'].each do |subdir|
          subdir_path = File.join(host_path, subdir)
          Dir.mkdir(subdir_path) unless File.exists? subdir_path
        end
      end

      # instantiate all templates and write output to tdd_deploy_configs
      erb_dir = File.join('lib', 'tdd_deploy', 'site-erb')
      # erb_dir = File.expand_path('../site-erb', __FILE__)
      Dir.new(erb_dir).each do |host_dir_fname|
        next if host_dir_fname[0] == '.'
        
        host_dir_path = File.join(erb_dir, host_dir_fname)
        
        Dir.new(host_dir_path).each do |subdir|
          next if subdir[0] == '.'
          
          subdir_path = File.join(host_dir_path, subdir)
          
          Dir.new(subdir_path).each do |fname|
            file_path = File.join(subdir_path, fname)
            next unless fname =~ /\.erb$/ && File.exists?(file_path)

            f = File.new(file_path)
            # '>' removes new-lines from lines ending in %>
            # template = ERB.new f.read, nil, '>'
            # '>' removes new-lines from lines starting with <% and ending in %>
            template = ERB.new f.read, nil, '<>'
            f.close
            
            file_content = template.result(binding)
            
            out_fname = File.basename(fname, '.erb')

            Dir.mkdir(subdir_path) unless File.exists? subdir_path
            out_path = File.join(tdd_deploy_configs, host_dir_fname, subdir, out_fname)

            f = File.new(out_path, "w")
            f.write template.result(binding)
            f.close
          
            # make files in 'app/site' executable
            File.chmod 0755, out_path if subdir == 'site'
          end
        end
      end
    end
  end
end
