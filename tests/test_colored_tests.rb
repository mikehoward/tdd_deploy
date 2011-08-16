$:.unshift File.expand_path('..', __FILE__)
require 'test_helpers'
require 'tdd_deploy/base'

# NOTES: These tests require a host to talk to. I run an Arch Linux server on my local
# machine as a virtual host. Set up your own with appropriate accounts if you need to run
# these tests.

class ColoredResult < TddDeploy::Base
  def passing_test
    deploy_test_on_all_hosts 'true', 'true always passes' do
      'echo "true"'
    end
  end
  
  def failing_test
    deploy_test_on_all_hosts 'false', 'false always fails' do
      'echo "true"'
    end
  end
end

class  ColoredResultTestCase < Test::Unit::TestCase
  def setup
    @tester = ColoredResult.new( { :host_admin => 'mike', :local_admin => 'mike', :db_hosts => 'arch', 
        :web_hosts => 'arch', :ssh_timeout => 2 } )
    @tester.reset_tests
  end
  
  def teardown
    @tester = nil
    # we need to delete this guy so it doesn't mess up the testing of server.rb
    TddDeploy::Base.children.delete ColoredResult
  end

  def test_passing_result
    @tester.passing_test
    test_results = @tester.test_results
    assert_match 'style="color:#0c0"', test_results, "Passing Test result should be colored Green: color:#0c0"
  end

  def test_failing_result
    @tester.failing_test
    test_results = @tester.test_results
    assert_match 'style="color:#c00"', test_results, "Passing Test result should be colored Red: color:#c00"
  end
end
