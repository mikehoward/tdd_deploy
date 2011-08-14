require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::SiteLayout
  #
  #  tests for the existence of several directories on all hosts as *site_user* in
  #  the *site_user* home directory.
  #
  #  The sub directories tested for are:
  #
  #     *site* - a directory named for the name of the site.
  #     *site*/releases - a standard directory used by Capistrano
  #     *site*/nginx.conf - an nginx configuratino fragment which tells nginx to
  #      proxy the site's *thin* servers
  #     *site*/monitrc - a monit configuration fragment which tells monit how to monitor
  #      the site's *thin* servers.
  class SiteLayout < TddDeploy::Base
    def test_site_subdir
      deploy_test_on_all_hosts_as self.site_user, "#{self.site}/", \
          "directory /home/#{self.site_user}/#{self.site} should exist" do
        'ls -F'
      end
    end

    def test_releases_subdir
      deploy_test_on_all_hosts_as self.site_user, "releases", \
          "directory /home/#{self.site_user}/#{self.site}/releases should exist" do
        "ls -F #{self.site}"
      end
    end

    def test_monitrc
      deploy_test_on_all_hosts_as self.site_user, 'monitrc', \
          "file /home/#{self.site_user}/monitrc should exist" do
            'ls'
      end
    end

    def test_nginx_conf
      deploy_test_on_all_hosts_as self.site_user, 'nginx.conf', \
          "file /home/#{self.site_user}/nginx.conf should exist" do
            'ls'
      end
    end
  end
end