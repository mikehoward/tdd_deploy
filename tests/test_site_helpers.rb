$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'

class SiteHelpersTestCase < SiteTestCase

  def setup
    ENV['SITE'] = 'mike'
    ENV['SITE_USER'] = 'mike'
    ENV['SITE_BASE_PORT'] = '9000'
    ENV['SITE_NUM_SERVERS'] = '12'
    super
  end

  def test_default_env
    # this idiocy removes the environment variables that setup uses in this test
    # and calls self.super.setup (if that were actually possible)
    ['SITE', 'SITE_USER', 'SITE_BASE_PORT', 'SITE_NUM_SERVERS'].each { |x| ENV.delete x }
    super_setup = SiteTestCase.instance_method :setup
    bound_super_setup = super_setup.bind self
    bound_super_setup.call

    assert_equal 'site', self.site, " should be 'site'"
    assert_equal 'site', self.site_user, " should be 'site'"
    assert_equal '8000'.to_i, self.site_base_port, " should be '8000'"
    assert_equal '3'.to_i, self.site_num_servers, " should be '3'"
  end

  def test_custom_env
    assert_equal 'mike', self.site, "site should be 'mike'"
    assert_equal 'mike', self.site_user, "site_user should be 'mike'"
    assert_equal 9000, self.site_base_port, "site_base_port should be 9000"
    assert_equal 12, self.site_num_servers, "site_num_servers should be 12"
  end
end
