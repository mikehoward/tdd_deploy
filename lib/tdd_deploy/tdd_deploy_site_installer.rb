#! /usr/bin/env ruby
#  -*- ruby-mode -*-

require 'erb'

module TddDeploy
  # == TddDeploySiteInstaller
  #
  # TddDeploySiteInstaller is used to create site/host specific configuration files for
  # sites. The files are defined by templates in subdirectories of the 'site-erb' directory.
  # At present there are templates in 'site-erb/config' and 'site-erb/site'. Rendered files
  # are written to corresponding subdirectories of the app. For example, 'site-erb/config/foo.erb'
  # will produce the file 'app/config/foo'
  #
  # files dropped into 'app/site/' are assumed to be executable, so their permissions are
  # set to 0755
  class SiteInstaller < TddDeploy::Base
    # install - reads all the templates in gem-home/site-erb, renders them using the
    #  current environment context, and writes the renderings to the appropriate
    #  files in app/sites and app/config
    def install
      erb_dir = File.expand_path('../../site-erb', __FILE__)

      Dir.new(erb_dir).each do |subdir|
        subdir_path = File.join(erb_dir, subdir)
        Dir.new(subdir_path).each do |fname|
          next unless fname =~ /\.erb$/

          f = File.new(File.join(erb_dir, fname))
          # '>' removes new-lines from lines ending in %>
          # template = ERB.new f.read, nil, '>'
          # '>' removes new-lines from lines starting with <% and ending in %>
          template = ERB.new f.read, nil, '<>'
          erb_src = f.close
          out_fname = File.basename(fname, '.erb')

          Dir.mkdir(subdir) unless File.exists? subdir
          out_path = File.join(subdir, out_fname)

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
