module TddDeploy
  module Assertions
    GREEN = '#080'
    RED   = '#800'
    GROUP_ELT_TAG = 'ul'
    HEADER_ELT_TAG = 'h2'
    RESULT_ELT_TAG = 'li'
    # TddDeploy re-implements popular assertions so that they can be used
    # in multi-host testing.
    #
    # These assertions differ from usual TDD assertions in that they do not stop
    # tests after failing. Rather they continue and accumulate failure counts and messages
    # which can be displayed using *announce_test_results()*.
    #
    # all assertions return boolean *true* or *false*

    # == Stats 
    #
    # Stats is a class which acts as a singleton container for test statistics & messages
    # test_count, messages, failiure count, and failure messages are all instance variables
    # of Stats. This avoids nasty complications which can come us when using instance,
    # class, and class-instance variables because the actual variables are defined when they
    # are initialized - which can easily differ from where they are declared.
    class Stats
      class << self
        attr_accessor :test_count, :failure_count, :failure_messages, :test_messages
      end
    end

    # Assertions all return true or false. The last parameter is always the assertions
    # message and is optional.
    #
    # assert(prediccate, msg) returns true if prediccate is true, else adds *msg*
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

    def assert_raises key, exception = Exception, msg, &block
      begin
        block.call
      rescue exception => e
        pass key, msg
        return true
      end
      fail key, msg
    end

    def refute key, predicate, msg
      assert_primative key, !predicate, msg
    end
  
    def refute_equal key, expect, value, msg
      assert_primative key, expect != value, msg
    end
  
    def pass key, msg
      assert_primative key, true, msg
    end

    def fail key, msg
      assert_primative key, false, msg
    end

    # public stats access

    # test_results returns the string string of all test messages
    def test_results
      str = ''
      Stats.test_messages.keys.sort.each do |key|
        str += test_results_for_key(key)
      end
      str
    end
    
    def test_results_for_key key
      str = "<#{GROUP_ELT_TAG} class=\"test-result-group\" id=\"test-result-group-#{key}\">\n<#{HEADER_ELT_TAG} class=\"test-result-header\" id=\"test-result-header-#{key}\">Results for '#{key}'</#{HEADER_ELT_TAG}>\n"
      if failure_count(key) == 0
        str += "<#{RESULT_ELT_TAG} class=\"test-result-summary-success\" id=\"test-result-summary-#{key}\">All #{test_count(key)} Tests Passed</#{RESULT_ELT_TAG}>\n"
      else
        str += "<#{RESULT_ELT_TAG} class=\"test-result-summary-failure\" id=\"test-result-summary-#{key}\">#{failure_count(key)} of #{test_count(key)} Tests Failed</#{RESULT_ELT_TAG}>\n"
      end
      toggle = true
      tmp = Stats.test_messages[key].map { |msg| toggle = !toggle ; "<#{RESULT_ELT_TAG} class=\"#{(toggle ? "even" : "odd")}\">#{msg}</#{RESULT_ELT_TAG}>\n" }
      str += tmp.join("\n") + "\n" if Stats.test_messages
      str + "</#{GROUP_ELT_TAG}>\n"
    end

   # failure_messages returns the failure_message hash
    def failure_messages
      Stats.failure_messages
    end
    
    # test_messages returns the test_message hash
    def test_messages
      Stats.test_messages
    end
    
    # reset_tests zeros out failure messages and count
    def reset_tests
      Stats.test_count = {}
      Stats.failure_count = {}
      Stats.failure_messages = {}
      Stats.test_messages = {}
    end

    def failure_count(key)
      Stats.failure_count ||= {}
      Stats.failure_count[key] ||= 0
    end

    def test_count(key)
      Stats.test_count ||= {}
      Stats.test_count[key] ||= 0
    end


    # private methods
    private
    def assert_primative key, predicate, msg
      predicate ? test_passed(key, "Passed: #{msg}") : test_failed(key, "Failed: #{msg}")
      predicate
    end
    
    # test message handling
    def test_failed(key, msg)
      msg = "<span class=\"test-result-detail test-result-detail-failure test-result-red\">#{msg}</span>"
      add_failure(key, msg)
      add_message(key, msg)
    end
    
    def test_passed(key, msg)
      msg = "<span class=\"test-result-detail test-result-detail-success test-result-green\">#{msg}</span>"
      add_message(key, msg)
    end

    def add_failure(key, msg)
      Stats.failure_messages ||= {}
      Stats.failure_messages[key] ||= []
      Stats.failure_messages[key].push(msg)

      Stats.failure_count[key] ||= 0
      Stats.failure_count[key] += + 1
    end

    def add_message(key, msg)
      Stats.test_messages ||= {}
      Stats.test_messages[key] ||= []
      Stats.test_messages[key].push(msg)

      Stats.test_count[key] ||= 0
      Stats.test_count[key] += 1
    end
    
    def self.included(mod)
      Stats.failure_count = {}
      Stats.failure_messages = {}

      Stats.test_count = {}
      Stats.test_messages = {}
    end
  end
end