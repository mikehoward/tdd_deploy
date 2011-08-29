require 'tdd_deploy/test_base'

module TddDeploy
  # == TddDeploy::SiteLayout
  #
  # tests for the existence of several directories on all hosts as *site_user* in
  # the *site_user* home directory.
  #
  # The sub directories tested for are:
  #
  # * 'site_app_root' - application root (current installed version)
  # * 'site_doc_root' - DocumentRoot
  # * 'site_doc_root'/../releases - a standard directory used by Capistrano
  # * 'site_doc_root'/config/thin.conf - config file for 'thin' server
  # * 'site_doc_root'/config/one_thin_server.conf - config file for monit to use to restart a single server instance
  # * '~/site/nginx.conf - an nginx configuratino fragment which tells nginx to proxy the site's *thin* servers
  # * ~/site/monitrc - a monit configuration fragment which tells monit how to monitor the site's *thin* servers.
  # * ~/site/one_thin_server - shell script to start a single server instance
  class SiteLayout < TddDeploy::TestBase
    def test_site_app_root
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{self.site_app_root}"
    end

    def test_site_doc_root
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{self.site_doc_root}"
    end

    def test_releases_subdir
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{self.site_app_root}/../../releases"
    end
    
    def test_special_dir
      deploy_test_file_exists_on_hosts_as self.site_user, self.hosts, self.site_special_dir
    end

    def test_thin_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{site_app_root}/config/thin.conf"
    end

    def test_one_thin_server_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{site_app_root}/config/one_thin_server.conf"
    end

    def test_site_dir_exists
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{site_special_dir}"
    end

    def test_monitrc
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{site_special_dir}/monitrc"
    end

    def test_nginx_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{site_special_dir}/nginx.conf"
    end

    def test_one_thin_server
      deploy_test_file_exists_on_hosts_as self.site_user, self.app_hosts, "#{site_special_dir}/one_thin_server"
    end
  end
end