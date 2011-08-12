# yes, I know this is re-inventing the wheel, but it makes this stuff easier and independent
# of differences between test/unit, minitest/unit, etc etc etc

module TddDeploy
  module Assertions
    def failure_count
      @failure_count || 0
    end

    def failure_count=(value = 1)
      @failure_count ||= 0
      value = value.to_int > 0 ? value.to_int : 1
      @failure_count += value
    end
    
    def failure_messages
      @failure_messages ||= []
    end

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

    def announce_test_results
      if self.failure_count > 0
        puts "#{self.failure_count} Failed Tests"
        puts self.failure_messages
      else
        puts "All tests passed"
      end
    end

    private
    def assert_primative predicate, msg = nil, caller_arg = 2
      unless predicate
        augmented_message = msg ? msg : "assertion failed"
        # unless augmented_message.instance_of? String
        #   caller.each do |s|
        #     puts s
        #   end
        # end
        augmented_message += "\nCalled from: #{caller(caller_arg).first}"
        self.failure_messages.push augmented_message
        self.failure_count += 1
        # puts augmented_message
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