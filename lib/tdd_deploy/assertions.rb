module TddDeploy
    # TddDeploy re-implements popular assertions so that they can be used
    # in multi-host testing.
    #
    # These assertions differ from usual TDD assertions in two ways:
    # * all assertions are 'keyed' - all the test results are grouped by
    # keys. 
    # * that they do not stop tests after failing. Rather they continue and 
    # accumulate failure counts and messages
    # which can be displayed using *announce_formatted_test_results()*.
    #
    # all assertions return boolean *true* or *false*
  module Assertions
    GROUP_ELT_TAG = 'ul'
    HEADER_ELT_TAG = 'h2'
    RESULT_ELT_TAG = 'li'

    # == Stats 
    #
    # Stats is a class which acts as a singleton container for test statistics & messages
    # test_count, messages, failiure count, and failure messages are all instance variables
    # of Stats. This avoids nasty complications which can come us when using instance,
    # class, and class-instance variables because the actual variables are defined when they
    # are initialized - which can easily differ from where they are declared.
    class Stats
      class << self
        attr_accessor :test_results
      end
    end

    # Assertions all return true or false. The last parameter is always the assertions
    # message and is optional.
    #
    # assert(key, prediccate, msg) returns true if prediccate is true, else adds *msg*
    # to failure messages and returns false
    def assert key, predicate, msg
      assert_primative key, predicate, msg
    end
  
    def assert_equal key, expect, value, msg
      assert_primative key, expect == value, msg
    end
    
    def assert_match key, regx, value, msg
      regx = Regexp.new(regx.to_s) unless regx.instance_of? Regexp
      assert_primative key, regx.match(value), msg
    end
  
    def assert_nil key, value, msg
      assert_primative key, value.nil?, msg
    end
  
    def assert_not_nil key, value, msg
      assert_primative key, !value.nil?, msg
    end

    # calls the block and passes only if 'block' raises 'exception'
    def assert_raises key, exception = Exception, msg, &block
      begin
        block.call
      rescue exception => e
        pass key, msg
        return true
      end
      fail key, msg
    end

    # refute assertions are simple negations of the corresponding assert
    def refute key, predicate, msg
      assert_primative key, !predicate, msg
    end
  
    def refute_equal key, expect, value, msg
      assert_primative key, expect != value, msg
    end
    
    def refute_nil key, predicate, msg  
      assert_primative key, !predicate, msg
    end
  
    # pass is used to insert a passing message for cases where an assertion is unnecessary
    def pass key, msg
      assert_primative key, true, msg
    end

    # fail, like 'pass', is used to insert a failure message where an assertion is unnecessary
    def fail key, msg
      assert_primative key, false, msg
    end

    # public stats access

    # don't use formatted_test_results or formatted_test_results_for_key
    # use the supplied test_results.html.erb template instead
    # formatted_test_results returns the string string of all test messages
    def formatted_test_results
      str = ''
      Stats.test_results.keys.sort.each do |key|
        str += formatted_test_results_for_key(key)
      end
      str
    end
    
    private
    def formatted_test_results_for_key key
      str = "<#{GROUP_ELT_TAG} class=\"test-result-group\" id=\"test-result-group-#{key}\">\n<#{HEADER_ELT_TAG} class=\"test-result-header\" id=\"test-result-header-#{key}\">Results for '#{key}'</#{HEADER_ELT_TAG}>\n"
      if failure_count(key) == 0
        str += "<#{RESULT_ELT_TAG} class=\"test-result-summary-success\" id=\"test-result-summary-#{key}\">All #{test_count(key)} Tests Passed</#{RESULT_ELT_TAG}>\n"
      else
        str += "<#{RESULT_ELT_TAG} class=\"test-result-summary-failure\" id=\"test-result-summary-#{key}\">#{failure_count(key)} of #{test_count(key)} Tests Failed</#{RESULT_ELT_TAG}>\n"
      end
      toggle = true
      tmp = Stats.test_results[key].map { |msg| toggle = !toggle ; "<#{RESULT_ELT_TAG} class=\"#{(toggle ? "even" : "odd")}\">#{msg}</#{RESULT_ELT_TAG}>\n" }
      str += tmp.join("\n") + "\n" if Stats.test_results
      str + "</#{GROUP_ELT_TAG}>\n"
    end
    
    public
    
    # test_results returns the test_results hash
    def test_results
      Stats.test_results
    end
    
    # reset_tests clears all test results
    def reset_tests
      Stats.test_results = {}
    end
    
    # removes all failed test results
    def remove_failed_tests
      tmp = {}
      Stats.test_results.each do |host, results|
        tmp[host] = results.select { |tmp| tmp[0] }
      end
      Stats.test_results = tmp
    end

    # total_failures: total number of failures accross all keys
    def total_failures
      count = 0
      Stats.test_results.values.each do |messages|
        count += messages.select { |msg| !msg[0] }.length
      end
      count
    end

    # total_tests: total number of tests accross all keys
    def total_tests
      Stats.test_results.values.reduce(0) { |memo, obj| memo += obj.length }
    end

    # number of failures recorded under 'key'
    def failure_count(key)
      return nil unless Stats.test_results[key]
      failure_messages(key).length
    end

    # number of tests recorded under 'key'
    def test_count(key)
      return nil unless Stats.test_results[key]
      Stats.test_results[key].length
    end

    # all tests messages saved under 'key', returns an array of 2-element arrays.
    # first element is 'true' or 'false' - indicates passed or failed
    # second element is the success message
    def test_messages(key)
      Stats.test_results[key]
    end
    
    # returns all failure messages in same format as 'test_messages(key)'.
    # this is simply: Stats.test_results[key].select { |tmp| !tmp[0] }
    def failure_messages(key)
      Stats.test_results[key].select { |tmp| !tmp[0] }
    end

    # private methods
    private
    def assert_primative key, predicate, msg
      predicate ? test_passed(key, "Passed: #{msg}") : test_failed(key, "Failed: #{msg}")
      predicate
    end
    
    # test message handling
    def test_failed(key, msg)
      add_message(key, false, msg)
    end
    
    def test_passed(key, msg)
      add_message(key, true, msg)
    end

    def add_message(key, result, msg)
      Stats.test_results ||= {}
      Stats.test_results[key] ||= []
      Stats.test_results[key].push([result, msg])
    end
    
    def self.included(mod)
      Stats.test_results = {}
    end
  end
end