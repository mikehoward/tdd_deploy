require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::SiteLayout
  #
  #  tests for the existence of several directories on all hosts as *site_user* in
  #  the *site_user* home directory.
  #
  #  The sub directories tested for are:
  #
  #     *site*.d - a directory named for the name of the site.
  #     *site*.d/releases - a standard directory used by Capistrano
  #     site/nginx.conf - an nginx configuratino fragment which tells nginx to
  #      proxy the site's *thin* servers
  #     site/monitrc - a monit configuration fragment which tells monit how to monitor
  #      the site's *thin* servers.
  class SiteLayout < TddDeploy::Base
    def test_site_subdir
      deploy_test_file_exists_on_all_hosts_as self.site_user, "#{self.site}.d/"
    end

    def test_releases_subdir
      deploy_test_file_exists_on_all_hosts_as self.site_user, "#{self.site}.d/releases"
    end

    def test_site_dir_exists
      deploy_test_file_exists_on_all_hosts_as self.site_user, 'site'
    end

    def test_monitrc
      deploy_test_file_exists_on_all_hosts_as self.site_user, 'site/monitrc'
    end

    def test_nginx_conf
      deploy_test_file_exists_on_all_hosts_as self.site_user, 'site/nginx.conf'
    end

    def test_thin_conf
      deploy_test_file_exists_on_all_hosts_as self.site_user, "#{site_path}/config/thin.conf"
    end

    def test_one_thin_server_conf
      deploy_test_file_exists_on_all_hosts_as self.site_user, '#{site_path}/one_thin_server.conf'
    end

    def test_one_thin_server
      deploy_test_file_exists_on_all_hosts_as self.site_user, 'site/one_thin_server'
    end
  end
end