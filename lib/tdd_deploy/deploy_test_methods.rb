require 'tdd_deploy/assertions'
require 'tdd_deploy/run_methods'

module TddDeploy
  module DeployTestMethods
    include TddDeploy::Assertions
    include TddDeploy::RunMethods
    
    # deploy_test_on_all_hosts runs the command(s) return by '&block' on all hosts in self.hosts
    # as user 'self.host_admin'.
    # For each host, an error is declared if EITHER STDOUT does not match 'match_expr_or_str'
    # OR if the command returns anything on STDERR.
    # 'match_expr_or_str' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_on_all_hosts(match_expr_or_str, err_msg, &block)
      deploy_test_on_all_hosts_as self.host_admin, match_expr_or_str, err_msg, &block
    end

    # deploy_test_on_all_hosts_as runs the command(s) return by '&block' on all hosts in self.hosts
    # as the specified user 'userid'.
    # For each host, an error is declared if EITHER STDOUT does not match 'match_expr_or_str'
    # OR if the command returns anything on STDERR.
    # 'match_expr_or_str' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_on_all_hosts_as(userid, match_expr_or_str, err_msg, &block)
      ret = true
      self.hosts.each do |host|
        ret &= deploy_test_in_ssh_session_as userid, host, match_expr_or_str, err_msg, &block
      end
      ret
    end

    # deploy_test_in_ssh_session host, match_exp_or_string, err_msg, &block runs the command
    # returned by 'block.call' on the specified host as user 'self.host_admin'.
    # declares an error if EITHER STDOUT does not match 'match' OR STDERR returns anything
    # 'match' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_in_ssh_session(host, match, err_msg, &block)
      deploy_test_in_ssh_session_as(self.host_admin, host, match, err_msg, &block)
    end

    # deploy_test_in_ssh_session_as runs the command(s) return by '&block' on the specified host
    # as user 'userid'
    # declares an error if EITHER STDOUT does not match 'match' OR STDERR returns anything
    # 'match' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_in_ssh_session_as(userid, host, match, err_msg, &block)
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError, 'match expression cannot be empty' if match =~ ''

      rsp, err_rsp, cmd = run_in_ssh_session_as(userid, host, &block)

      result = err_rsp.nil?
      
      prefix = "user@host: #{userid}@#{host}"

      fail "<pre>\n#{prefix}: command generated error data:\n" +
        "  command: #{cmd}\n stdout: '#{rsp}'\n stderr: '#{err_rsp}'\n</pre>" if err_rsp

      if !assert_not_nil rsp, "#{prefix}: stdout is empty for command '#{cmd}'"
        result &= false
      elsif !assert_match match, rsp, "#{prefix}: #{err_msg}\n rsp: #{rsp}"
        result &= false
      end

      result
    end
  end
end
