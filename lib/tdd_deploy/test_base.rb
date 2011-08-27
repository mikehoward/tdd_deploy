require 'tdd_deploy/base'

module TddDeploy
  # == TddDeploy::TestBase
  #
  # provides a base class for host and site tests.
  class TestBase < TddDeploy::Base
    # gather up all descendents so we know what tests to run
    class <<self
      attr_writer :children

      def children
        @children ||= []
      end
      
      # removes all methods from defined children.
      def flush_children_methods
        self.children.each do |child|
          child.instance_methods(false).each do |meth|
            child.send :remove_method, meth
          end
        end
      end
      
      def inherited(child)
        self.children ||= []
        self.children << child unless self.children.include? child
      end
    end
  end
end
