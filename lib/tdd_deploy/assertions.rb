module TddDeploy
  module Assertions
    # TddDeploy re-implements popular assertions so that they can be used
    # in multi-host testing.
    #
    # These assertions differ from usual TDD assertions in that they do not stop
    # tests after failing. Rather they continue and accumulate failure counts and messages
    # which can be displayed using *announce_test_results()*.
    #
    # all assertions return boolean *true* or *false*
    
    # failure_count returns the number failures recorded since inception or the last
    # call to either *clear_failure_stats* or *announce_test_results*
    def failure_count
      @failure_count ||= 0
    end

    def failure_count=(value = 1)
      @failure_count ||= 0
      value = value.to_int > 0 ? value.to_int : 1
      @failure_count = value
    end
    
    # failure_messages returns an array of accumulated failure messages
    def failure_messages
      @failure_messages ||= []
    end

    # announce_test_results(verbose = false) prints out the current number
    # of failures and the accumulation failure messages. It announces that
    # all tests have passed if there are no failures recorded and verbose is true
    #
    # failure counts and messages are cleared.
    def announce_test_results verbose = false
      puts test_results_str(verbose)
    end
    
    # test_results_str(verbose = false) returns the string printed by *announce_test_results*
    def test_results_str verbose = false
      if self.failure_count > 0
        return "#{self.failure_count} Failed Tests\n\n" + self.failure_messages.join("\n\n")
      elsif verbose
        return "All tests passed: #{caller}"
      end
      self.clear_failure_stats
      ''
    end
    
    # clear_failure_stats zeros out failure messages and count
    def clear_failure_stats
      @failure_messages = []
      @failure_count = 0
    end

    # Assertions all return true or false. The last parameter is always the assertions
    # message and is optional.
    #
    # assert(prediccate, msg = nil) returns true if prediccate is true, else adds *msg*
    # to failure messages and returns false
    def assert predicate, msg = nil
      assert_primative predicate, msg
    end
  
    def assert_equal expect, value, msg = nil
      assert_primative expect == value, msg
    end
    
    def assert_match regx, value, msg = nil
      regx = Regexp.new(regx.to_s) unless regx.instance_of? Regexp
      assert_primative regx.match(value), msg
    end
  
    def assert_nil value, msg = nil
      assert_primative value.nil?, msg
    end
  
    def assert_not_nil value, msg = nil
      assert_primative !value.nil?, msg
    end

    def assert_raises exception = Exception, msg = nil, &block
      begin
        block.call
      rescue exception => e
        return true
      end
      assert_primative false, msg
    end

    def refute predicate, msg = nil
      assert_primative !predicate, msg
    end
  
    def refute_equal expect, value, msg = nil
      assert_primative expect != value, msg
    end
  
    def pass msg = nil
      assert_primative true, msg
    end

    def fail msg = nil
      assert_primative false, msg
    end

    private
    def assert_primative predicate, msg = nil, caller_arg = 2
      unless predicate
        augmented_message = msg ? msg : "assertion failed"
        augmented_message += "\nCalled from: #{caller(caller_arg).first}"
        self.failure_messages.push augmented_message
        self.failure_count += 1
        false
      else
        STDOUT.write('.') ; STDOUT.flush
        true
      end
    end

    def included(base)
      at_exit do
        announce_test_results
      end
    end
  end
end