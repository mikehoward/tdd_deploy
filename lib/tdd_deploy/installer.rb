require 'tdd_deploy/base'
require 'tdd_deploy/copy_methods'

module TddDeploy
  class Installer < TddDeploy::Base
    include TddDeploy::CopyMethods

    def install_config_files_on_host_list_as userid, host_list_name
      raise ::ArgumentError.new("install_config_files_on_host_list_as(userid, host_list_name): invalid host_list_name: #{host_list_name}") \
          unless self.respond_to? host_list_name.to_sym
      config_dir = File.join(self.site_doc_root, '..', 'config')
      src_dir = File.join('tdd_deploy_configs', host_list_name.to_s, 'config')
      copy_dir_to_remote_hosts_as userid, rationalize_host_list(host_list_name), src_dir, config_dir
    end

    def install_special_files_on_host_list_as userid, host_list_name
      raise ::ArgumentError.new("install_config_files_on_host_list_as(userid, host_list_name): invalid host_list_name: #{host_list_name}") \
          unless self.respond_to? host_list_name.to_sym
      result = run_on_hosts_as(userid, host_list_name, "rm #{self.site_special_dir}/*")
      return false unless result
      
      append_dir_to_remote_hosts_as userid, rationalize_host_list(host_list_name), File.join('tdd_deploy_configs', host_list_name.to_s, 'site'),
        self.site_special_dir
    end
    
    def run_cap_deploy
      stdout, stderr, cmd = run_locally { 'cap deploy:update' }
  puts "run_locally: stdout: #{stdout}"
  puts "run_locally: stderr: #{stderr}"
      return stderr.nil?
    end
  end
end
