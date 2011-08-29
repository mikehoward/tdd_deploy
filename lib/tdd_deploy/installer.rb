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

    def empty_special_dir userid, host_list_name
      raise ::ArgumentError.new("install_config_files_on_host_list_as(userid, host_list_name): invalid host_list_name: #{host_list_name}") \
          unless self.respond_to? host_list_name.to_sym
      host_list = rationalize_host_list host_list_name
      run_on_hosts_as(userid, host_list, "rm #{self.site_special_dir}/*")
    end

    def install_special_files_on_host_list_as userid, host_list_name
      raise ::ArgumentError.new("install_config_files_on_host_list_as(userid, host_list_name): invalid host_list_name: #{host_list_name}") \
          unless self.respond_to? host_list_name.to_sym
      
      host_list = rationalize_host_list host_list_name
      src_dir = File.join('tdd_deploy_configs', host_list_name.to_s, 'site')
      append_dir_to_remote_hosts_as userid, host_list, src_dir, self.site_special_dir
    end
    
    def run_cap_deploy
      stdout, stderr, cmd = run_locally { 'cap deploy:update' }
      return false if stderr =~ /failed|rolling back/
      return true
    end
  end
end
