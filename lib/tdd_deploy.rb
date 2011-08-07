$:.unshift File.expand_path('..', __FILE__)

require 'active_support/concern'
#   require 'active_support/concern'
#
#   module Foo
#     extend ActiveSupport::Concern
#     included do
#       class_eval do
#         def self.method_injected_by_foo
#           ...
#         end
#       end
#     end
#   end
#
#   module Bar
#     extend ActiveSupport::Concern
#     include Foo
#
#     included do
#       self.method_injected_by_foo
#     end
#   end
#
#   class Host
#     include Bar # works, Bar takes care now of its dependencies
#   end

require 'tdd_deploy/environ'
require 'tdd_deploy/run_methods'
require 'tdd_deploy/deploy_test_methods'

module TddDeploy
  extend ActiveSupport::Concern

  # include core methods
  include TddDeploy::Environ
  include TddDeploy::RunMethods
  include TddDeploy::DeployTestMethods
end
