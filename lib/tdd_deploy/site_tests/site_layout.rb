require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::SiteLayout
  #
  # tests for the existence of several directories on all hosts as *site_user* in
  # the *site_user* home directory.
  #
  # The sub directories tested for are:
  #
  # * 'site_doc_root' - DocumentRoot
  # * 'site_doc_root'/../releases - a standard directory used by Capistrano
  # * 'site_doc_root'/config/thin.conf - config file for 'thin' server
  # * 'site_doc_root'/config/one_thin_server.conf - config file for monit to use to restart a single server instance
  # * '~/site/nginx.conf - an nginx configuratino fragment which tells nginx to proxy the site's *thin* servers
  # * ~/site/monitrc - a monit configuration fragment which tells monit how to monitor the site's *thin* servers.
  # * ~/site/one_thin_server - shell script to start a single server instance
  class SiteLayout < TddDeploy::Base
    def test_site_subdir
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{self.site_doc_root}"
    end

    def test_releases_subdir
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{self.site_doc_root}/../releases"
    end

    def test_thin_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{site_doc_root}/config/thin.conf"
    end

    def test_one_thin_server_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "#{site_doc_root}/config/one_thin_server.conf"
    end

    def test_site_dir_exists
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "~/site"
    end

    def test_monitrc
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "~/site/monitrc"
    end

    def test_nginx_conf
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "~/site/nginx.conf"
    end

    def test_one_thin_server
      deploy_test_file_exists_on_hosts_as self.site_user, self.web_hosts, "~/site/one_thin_server"
    end
  end
end