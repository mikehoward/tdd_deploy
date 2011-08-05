$:.unshift File.expand_path('..', __FILE__)

require 'tdd_deploy/run_methods'
require 'tdd_deploy/test_methods'

module TddDeploy
  
  # set up standard accessors
  def self.included(mod)
    {
      'ssh_timeout' => 5,
      'host_admin' => "'host_admin'",
      'hosts' => "''",
      'local_admin' => "'local_admin'",
      'local_admin_email' => "'local_admin@bogus.tld'",
      
      'site' => "'site'",
      'site_user' => "'site_user'",
      'site_base_port' => 8000,
      'site_num_servers' => 3,
    }.each do |k, v|
      tmp =<<-EOF
      def #{k}
        @#{k} ||= #{v}
      end
      def #{k}=(val)
        @#{k} = val
      end
      EOF

      mod.class_eval tmp
    end
  end

  # include core methods
  include TddDeploy::RunMethods
  include TddDeploy::TestMethods
end
