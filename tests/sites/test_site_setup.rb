$:.unshift File.expand_path('../..', __FILE__)
require 'test_helpers'

class SiteSetupTestCase < SiteTestCase

  def test_true
    assert true, 'true is true'
  end

  def test_site_user_can_login
    run_on_all_hosts_as self.site_user, "/home/#{self.site_user}", "#{site_user} can log in" do
      'pwd'
    end
  end

#  def test_sites_dir_exists
#    run_on_all_hosts 
#  end
end


