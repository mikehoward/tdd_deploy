module TddDeploy
  module Assertions
    GREEN = '#0c0'
    RED   = '#c00'
    WRAP_ELT_TAG = 'p'
    # TddDeploy re-implements popular assertions so that they can be used
    # in multi-host testing.
    #
    # These assertions differ from usual TDD assertions in that they do not stop
    # tests after failing. Rather they continue and accumulate failure counts and messages
    # which can be displayed using *announce_test_results()*.
    #
    # all assertions return boolean *true* or *false*


    attr_reader :test_count, :failure_count, :failure_messages, :test_messages

    # test_results returns the string string of all test messages
    def test_results
      unless self.failure_count.nil? || self.failure_count == 0
        str = "#{self.failure_count} Failed Test" + (self.failure_count == 1 ? '' : 's')
      else
        str = ''
      end
      self.test_messages ? str + self.test_messages.join("\n") : str
    end
    
    def test_failures
      return '' unless self.failure_count > 0
      "<#{WRAP_ELT_TAG} style=\"color:#{RED}\">Failed #{self.failure_count} tests</#{WRAP_ELT_TAG}>\n" + self.failure_messages.join("\n")
    end
    
    # reset_tests zeros out failure messages and count
    def reset_tests
      @test_count =
        @failure_count = 0
      @failure_messages = []
      @test_messages = []
    end

    # Assertions all return true or false. The last parameter is always the assertions
    # message and is optional.
    #
    # assert(prediccate, msg) returns true if prediccate is true, else adds *msg*
    # to failure messages and returns false
    def assert predicate, msg
      assert_primative predicate, msg
    end
  
    def assert_equal expect, value, msg
      assert_primative expect == value, msg
    end
    
    def assert_match regx, value, msg
      regx = Regexp.new(regx.to_s) unless regx.instance_of? Regexp
      assert_primative regx.match(value), msg
    end
  
    def assert_nil value, msg
      assert_primative value.nil?, msg
    end
  
    def assert_not_nil value, msg
      assert_primative !value.nil?, msg
    end

    def assert_raises exception = Exception, msg, &block
      begin
        block.call
      rescue exception => e
        return true
      end
      assert_primative false, msg
    end

    def refute predicate, msg
      assert_primative !predicate, msg
    end
  
    def refute_equal expect, value, msg
      assert_primative expect != value, msg
    end
  
    def pass msg
      assert_primative true, msg
    end

    def fail msg
      assert_primative false, msg
    end

    # private methods
    private
    def assert_primative predicate, msg
      predicate ? test_passed("Passed: #{msg}") : test_failed("Failed: #{msg}")
      predicate
    end
    
    # test message handling
    def test_failed(msg)
      msg = "<#{WRAP_ELT_TAG} style=\"color:#{RED}\">#{msg}</#{WRAP_ELT_TAG}>"
      add_failure(msg)
      add_message(msg)
    end
    
    def test_passed(msg)
      msg = "<#{WRAP_ELT_TAG} style=\"color:#{GREEN}\">#{msg}</#{WRAP_ELT_TAG}>"
      add_message(msg)
    end

    def add_failure(msg)
      @failure_messages ||= []
      @failure_count ||= 0
      @failure_messages.push(msg)
      @failure_count += 1
    end

    def add_message(msg)
      @test_messages ||= []
      @test_count ||= 0
      @test_messages.push(msg)
      @test_count += 1
    end
  end
end