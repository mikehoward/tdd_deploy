module TddDeploy
  module RunMethods
    require 'net/ssh'
    
    # runs the output of the block on all hosts defined in self.hosts as user self.host_admin.
    # Returns a hash of two element arrays containing output [stdout, stderr] returned from the command.
    # Hash keys are host names as strings.
    def run_on_all_hosts(cmd = nil, &block)
      run_on_all_hosts_as self.host_admin, cmd, &block
    end

    # Runs the output of the block on all hosts defined in self.hosts as user 'userid'.
    # Returns a hash of two element arrays containing output [stdout, stderr] returned from the command.
    # Hash keys are host names as strings.
    def run_on_all_hosts_as(userid, cmd = nil, &block)
      run_on_hosts_as userid, self.hosts, cmd, &block
    end
    
    # runs supplied command on list of hosts as specified user
    def run_on_hosts_as userid, host_list, cmd = nil, &block
      host_list = [host_list] if host_list.is_a? String
      result = {}
      host_list.uniq.each do |host|
        result[host] = run_in_ssh_session_on_host_as userid, host, cmd, &block
      end
      result
    end

    # Runs the command secified in &block on 'host' as user 'self.host_admin'.
    # Returns an array [stdout, stderr] returned from the command.
    def run_in_ssh_session(host, cmd = nil, &block)
      run_in_ssh_session_on_host_as(self.host_admin, host, cmd, &block)
    end

    # Runs the command secified in &block on 'host' as user 'userid'.
    # Returns an array [stdout, stderr] returned from the command.
    def run_in_ssh_session_on_host_as(userid, host, cmd = nil, &block)
      login = "#{userid}@#{host}"
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError.new('match expression cannot be empty') if match =~ ''

      rsp = nil
      err_rsp = nil
      cmd = block.call if block_given?
      raise ArgumentError.new('cmd cannot be empty') if cmd.empty?

      begin
        ssh_session = Net::SSH.start(host, userid, :timeout => self.ssh_timeout, :languages => 'en')
        raise "Unable to establish connecton to #{host} as #{userid}" if ssh_session.nil?

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
          
          channel.wait
        end

        # must do this or the channel only runs once
        ssh_session.loop(5)

        ssh_session.close
      rescue Exception => e
        err_rsp = "error talking to #{host} as #{userid}: #{e.message}"
        ssh_session.shutdown! unless ssh_session.nil?
      end
      [rsp, err_rsp, cmd]
    end

  
    # run locally runs a comman locally and returns the output of stdout, stderr, and the command
    # run in a 3 element array
    #
    # to send input to the subprocess, include the optional 'stdin_text' parameter. Don't
    # forget to add newlines, if you need them.
    def run_locally(stdin_text = nil, &block)
      raise ArgumentError.new('block required') unless block_given?

      cmd = block.call
      # cmd = "echo '#{stdin_text}' | #{cmd}" if stdin_text

      raise "Unable to run_locally - fork method not useable" unless Process.respond_to? :fork

      # preload stdin if there is input to avoid a race condition
      if stdin_text
        stdin_pipe, child_stdin = IO.pipe if stdin_text
        count = child_stdin.write(stdin_text.to_s)
        child_stdin.close
      end

      child_stdout, stdout_pipe = IO.pipe
      child_stderr, stderr_pipe = IO.pipe
      unless (pid = Process.fork)
        if stdin_text
          STDIN.reopen(stdin_pipe)
        else
          STDIN.close
        end
        STDOUT.reopen(stdout_pipe)
        STDERR.reopen(stderr_pipe)
        begin
          Process.exec ENV, cmd
        rescue SystemCallError => e
          STDERR.write("Unable to execute command '#{cmd}'\n  #{e}")
        ensure
          exit
        end
      end

      Process.wait

      stdout = ''
      stderr = ''
      loop do
        reads, writes, obands = IO.select([child_stdout, child_stderr], [], [], 1)
        break if reads.nil?
        stdout += child_stdout.read_nonblock(1024) if reads.include? child_stdout
        stderr += child_stderr.read_nonblock(1024) if reads.include? child_stderr
      end
      stdout = nil if stdout.empty?
      stderr = nil if stderr.empty?

      [stdout, stderr, cmd]
    end

  end
end
