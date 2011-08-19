require 'tdd_deploy/assertions'
require 'tdd_deploy/run_methods'

module TddDeploy
  module DeployTestMethods
    include TddDeploy::Assertions
    include TddDeploy::RunMethods

    def deploy_test_process_running_on_all_hosts pid_file_path, success_msg = nil
      deploy_test_process_running_on_all_hosts_as self.host_admin, pid_file_path, success_msg
    end
    
    def deploy_test_process_running_on_all_hosts_as(userid, pid_file_path, success_msg = nil)
      success_msg ||= "Process associated with #{pid_file_path} should be running"
      ret = deploy_test_file_exists_on_all_hosts_as(userid, pid_file_path, success_msg + " no such pid file: #{pid_file_path}") ||
      ret &= deploy_test_on_all_hosts_as(userid, /.+\n\s*\d+.*?\d\d:\d\d:\d\d/, "Process for #{pid_file_path} is running") do
        "ps -p `cat #{pid_file_path} | awk '{ print $1 ; exit }'`"
      end
    end

    def deploy_test_file_exists_on_all_hosts(path, success_msg = nil)
      deploy_test_file_exists_on_all_hosts_as(self.host_admin, path, success_msg)
    end

    def deploy_test_file_exists_on_all_hosts_as(userid, path, success_msg = nil)
      deploy_test_on_all_hosts_as(userid, /^\s*success\s*$/, success_msg || "path #{path} should exist") do
        "test -s #{path} && echo success || echo fail"
      end
    end
    
    # deploy_test_on_all_hosts runs the command(s) return by '&block' on all hosts in self.hosts
    # as user 'self.host_admin'.
    # For each host, an error is declared if EITHER STDOUT does not match 'match_expr_or_str'
    # OR if the command returns anything on STDERR.
    # 'match_expr_or_str' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_on_all_hosts(match_expr_or_str, success_msg, &block)
      deploy_test_on_all_hosts_as self.host_admin, match_expr_or_str, success_msg, &block
    end

    # deploy_test_on_all_hosts_as runs the command(s) return by '&block' on all hosts in self.hosts
    # as the specified user 'userid'.
    # For each host, an error is declared if EITHER STDOUT does not match 'match_expr_or_str'
    # OR if the command returns anything on STDERR.
    # 'match_expr_or_str' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_on_all_hosts_as(userid, match_expr_or_str, success_msg, &block)
      ret = true
      self.hosts.each do |host|
        ret &= deploy_test_in_ssh_session_as userid, host, match_expr_or_str, success_msg, &block
      end
      ret
    end

    # deploy_test_in_ssh_session host, match_exp_or_string, success_msg, &block runs the command
    # returned by 'block.call' on the specified host as user 'self.host_admin'.
    # declares an error if EITHER STDOUT does not match 'match' OR STDERR returns anything
    # 'match' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_in_ssh_session(host, match, success_msg, &block)
      deploy_test_in_ssh_session_as(self.host_admin, host, match, success_msg, &block)
    end

    # deploy_test_in_ssh_session_as runs the command(s) return by '&block' on the specified host
    # as user 'userid'
    # declares an error if EITHER STDOUT does not match 'match' OR STDERR returns anything
    # 'match' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_in_ssh_session_as(userid, host, match, success_msg, &block)
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError, 'match expression cannot be empty' if match =~ ''

      rsp, err_rsp, cmd = run_in_ssh_session_as(userid, host, &block)

      result = err_rsp.nil?
      
      prefix = "user@host: #{userid}@#{host}: #{success_msg}"

      fail host, "#{prefix}: command generated error data:\n" +
        "  command: #{cmd}\n stdout: '#{rsp}'\n stderr: '#{err_rsp}'" if err_rsp

      if rsp.nil?
        fail host, "#{prefix}: stdout is empty for command '#{cmd}'"
        result &= false
      elsif !assert_match host, match, rsp, prefix
        result &= false
      end

      result
    end
  end
end
