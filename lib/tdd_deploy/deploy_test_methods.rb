require 'tdd_deploy/assertions'
require 'tdd_deploy/run_methods'

module TddDeploy
  # == TddDeploy::DeployTestMethods
  #
  # this module supplies the basic methods used to validate host installation structure.
  #
  # all methods expect the first two arguments to be 'userid' and 'host' or 'host-list'.
  # the 'userid' is a userid which exists on the specified host.
  # 'host' is a single host
  # 'host-list' can be a single host (as a string) or an array of host names
  # 'success_message' is what you will see in the report. I like positive messages, hence the name
  #
  # the most frequently used are 'deploy_test_process_running_on_hosts_as' and 'deploy_test_file_exists_on_hosts_as'.
  #
  # 'deploy_test_on_hosts_as' and 'deploy_test_in_ssh_session_as' are more primative and flexible.
  module DeployTestMethods
    include TddDeploy::Assertions
    include TddDeploy::RunMethods
    
    def deploy_test_process_running_on_hosts_as(userid, host_list, pid_file_path, success_msg = nil)
      success_msg ||= "Process associated with #{pid_file_path} should be running"
      ret = deploy_test_file_exists_on_hosts_as(userid, host_list, pid_file_path, success_msg + " no such pid file: #{pid_file_path}") ||
      ret &= deploy_test_on_hosts_as(userid, host_list, /.+\n\s*\d+.*?\d\d:\d\d:\d\d/, "Process for #{pid_file_path} is running") do
        "ps -p `cat #{pid_file_path} | awk '{ print $1 ; exit }'`"
      end
    end

    def deploy_test_file_exists_on_hosts_as(userid, host_list, path, success_msg = nil)
      deploy_test_on_hosts_as(userid, host_list, /^\s*success\s*$/, success_msg || "path #{path} should exist") do
        "test -s #{path} && echo success || echo fail"
      end
    end

    # deploy_test_on_hosts_as runs the command(s) return by '&block' on hosts in 'host_list'
    # as the specified user 'userid'.
    # For each host, an error is declared if EITHER STDOUT does not match 'match_expr_or_str'
    # OR if the command returns anything on STDERR.
    # 'match_expr_or_str' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_on_hosts_as userid, host_list, match_expr_or_str, success_msg, &block
      ret = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        ret &= deploy_test_in_ssh_session_as userid, host, match_expr_or_str, success_msg, &block
      end
      ret
    end

    # deploy_test_in_ssh_session_as runs the command(s) return by '&block' on the specified host
    # as user 'userid'
    # declares an error if EITHER STDOUT does not match 'match' OR STDERR returns anything
    # 'match' can be a Regexp or a string (which will be converted to a Regexp)
    def deploy_test_in_ssh_session_as(userid, host, match, success_msg, &block)
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError, 'match expression cannot be empty' if match =~ ''

      rsp, err_rsp, cmd = run_in_ssh_session_on_host_as(userid, host, &block)

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
