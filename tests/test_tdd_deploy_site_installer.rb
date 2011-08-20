$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'tdd_deploy/site_installer'

class TestTddDeploySiteInstallerrTestCase < Test::Unit::TestCase
  def setup
    @installer = TddDeploy::SiteInstaller.new
  end
  
  def teardown
    @installer = nil
  end
  
  def test_installer_is_an_object
    assert @installer.is_a?(TddDeploy::SiteInstaller), "@installer shold be a SiteInstaller object"
  end
end
