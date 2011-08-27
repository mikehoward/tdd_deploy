require 'tdd_deploy/base'
require 'tdd_deploy/copy_methods'

module TddDeploy
  class Installer < TddDeploy::Base
    include TddDeploy::CopyMethods

    def install_special_files_on_host_list_name_as userid, host_list_name
      host_list = self.send host_list_name.to_sym
      result = run_on_hosts_as(userid, host_list, "rm #{self.site_special_dir}/*")
      return false unless result
      
      append_dir_to_remote_hosts_as userid, host_list, File.join('tdd_deploy_configs', host_list_name, 'site'),
        self.site_special_dir
    end
  end
end
