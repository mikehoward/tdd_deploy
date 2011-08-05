module TddDeploy
  module RunMethods
    attr_accessor :host_admin, :hosts, :local_admin_email, :local_admin

    def run_on_all_hosts(match_expr_or_str, err_msg, &block)
      run_on_all_hosts_as self.host_admin, match_expr_or_str, err_msg, &block
    end

    def run_on_all_hosts_as(userid, match_expr_or_str, err_msg, &block)
      self.hosts.each do |host|
        run_in_ssh_session_as userid, host, match_expr_or_str, err_msg, &block
      end
    end

    # run_in_ssh_session host, match_exp_or_string, err_msg, &block
    def run_in_ssh_session(host, match, err_msg, &block)
      run_in_ssh_session_as(self.host_admin, host, match, err_msg, &block)
    end

    def run_in_ssh_session_as(userid, host, match, err_msg, &block)
      login = "#{userid}@#{host}"
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError, 'match expression cannot be empty' if match =~ ''

      begin
        ssh_session = Net::SSH.start(host, userid)

        cmd = block.call(host, login, userid)
        rsp = ''
        err_rsp = nil

        ssh_session.open_channel do |channel|
          channel.exec(cmd) do |ch, success|
            ch.on_data do |chn, data|
              rsp ||= ''
              rsp += data.to_s
            end

            ch.on_extended_data do |chn, data|
              err_rsp ||= ''
              err_rsp += data.to_s
            end

          end
        end

        # must do this or the channel only runs once
        ssh_session.loop

        flunk "Host: #{host}: command generated error data:\n" +
          "  command: #{cmd}\n rsp: '#{rsp}\n err rsp: '#{err_rsp}'" if err_rsp

        refute_nil rsp, "Host: #{host}: stdout is empty for command '#{cmd}'"

        assert_match match, rsp, "Host: #{host}: #{err_msg}\n rsp: #{rsp}"

        ssh_session.close
      rescue Exception => e
        flunk("error talking to #{host} as #{userid}: #{e.message}")
        ssh_session.shutdown! if ssh_session instance_of? Capistrano::SSH
      end
    end
  end
end
