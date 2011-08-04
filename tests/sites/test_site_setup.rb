$:.unshift File.expand_path('../..', __FILE__)
require 'test_helpers'

class SiteSetupTestCase < SiteTestCase

  def test_true
    assert true, 'true is true'
  end
end


