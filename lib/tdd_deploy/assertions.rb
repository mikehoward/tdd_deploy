# yes, I know this is re-inventing the wheel, but it makes this stuff easier and independent
# of differences between test/unit, minitest/unit, etc etc etc

module TddDeploy
  module Assertions
    def assert predicate, msg = nil
      assert_primative predicate, msg
    end
    
    def assert_equal expect, value, msg = nil
      assert_primative expect == value, msg
    end
    
    def assert_nil value, msg = nil
      assert_primative value.nil?, msg
    end
    
    def assert_not_nil value, msg = nil
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

    def refute predicate, msg = nil
      assert_primative !predicate, msg
    end
    
    def refute_equal expect, value, msg = nil
      assert_primative expect != value, msg
    end

    private
    def assert_primative predicate, msg = nil, caller_arg = 2
      unless predicate
        augmented_msg = (msg ? msg : "assertion failed") + "\nCalled from: #{caller(caller_arg).first}"
        false
      else
        STDOUT.write('.') ; STDOUT.flush
        true
      end
    end
  end
end