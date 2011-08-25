#! /usr/bin/env ruby
#  -*- ruby-mode -*-

require 'erb'
require 'tdd_deploy/base'

module TddDeploy
  # == TddDeployConfigurator
  #
  # NOTE: you generally do NOT use the TddDeploy::Configurator class directly. You will
  # seed your configuration files using the supplied 'rake' task; edit, modify, delete,
  # spindle, fold and mutilate as you please; and then, click the 'Run configurator'
  # link in the server page.
  #
  # TddDeploy::Configurator is used to create site/host specific configuration files for
  # sites. The files are defined by templates in subdirectories of the 'site-erb' directory.
  #
  # templates are installed in your app's 'lib/tdd_deploy/site-erb' directory. There are
  # three subdirectories - one for each server class: balance_hosts, db_hosts, and web_hosts.
  #
  # Templates actually reside in subdirectories which correspond to installation directories
  # on the deployment hosts. Thus, templates for the 'config' directory for the 'balance_hosts'
  # are in 'lib/tdd_deploy/site-erb/balance_hosts/config'
  #
  # I put other config files and executables in the directory 'site'. At present these are
  # include files for 'nginx' and 'monit'.
  #
  # At present there are templates in 'site-erb/config' and 'site-erb/site'. Rendered files
  # are written to corresponding subdirectories of 'tdd_deploy_configs'
  # in your application.
  #
  # It's your problem to deal with file permission issues.
  class Configurator < TddDeploy::Base
    # install - reads all the templates in gem-home/site-erb, renders them using the
    #  current environment context, and writes the renderings to the appropriate
    #  files in app/sites and app/config
    def make_configuration_files
      # create local directory for output files
      tdd_deploy_configs = File.join Dir.pwd, 'tdd_deploy_configs'
      Dir.mkdir(tdd_deploy_configs) unless File.exists? tdd_deploy_configs

      ['app_hosts', 'balance_hosts', 'db_hosts', 'web_hosts'].each do |host_dir|
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
