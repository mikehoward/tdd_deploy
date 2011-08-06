module TddDeploy
  module RunMethods
    # runs the output of the block on all hosts defined in self.hosts as user self.host_admin.
    # Returns a hash of two element arrays containing output [stdout, stderr] returned from the command.
    # Hash keys are host names as strings.
    def run_on_all_hosts(&block)
      run_on_all_hosts_as self.host_admin, &block
    end

    # Runs the output of the block on all hosts defined in self.hosts as user 'userid'.
    # Returns a hash of two element arrays containing output [stdout, stderr] returned from the command.
    # Hash keys are host names as strings.
    def run_on_all_hosts_as(userid, &block)
      results = {}
      self.hosts.each do |host|
        results[host] = run_in_ssh_session_as(userid, host, &block)
      end
      results
    end

    # Runs the command secified in &block on 'host' as user 'self.host_admin'.
    # Returns an array [stdout, stderr] returned from the command.
    def run_in_ssh_session(host, &block)
      run_in_ssh_session_as(self.host_admin, host, &block)
    end

    # Runs the command secified in &block on 'host' as user 'userid'.
    # Returns an array [stdout, stderr] returned from the command.
    def run_in_ssh_session_as(userid, host, &block)
      login = "#{userid}@#{host}"
      match = Regexp.new(match) if match.is_a? String
      raise ArgumentError, 'match expression cannot be empty' if match =~ ''

      rsp = nil
      err_rsp = nil
      cmd = block.call(host, login, userid)

      begin
        ssh_session = Net::SSH.start(host, userid, :timeout => self.ssh_timeout)
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
  end
  
  # run locally runs a comman locally and returns the output of stdout, stderr, and the command
  # run in a 3 element array
  def run_locally cmd = nil, &block
    cmd ||= ''
    cmd += block.call if block_given?

    raise "Unable to run_locally - fork method not useable" unless Process.respond_to? :fork

    child_stdout, stdout_pipe = IO.pipe
    child_stderr, stderr_pipe = IO.pipe
    unless (pid = Process.fork)
      STDIN.close
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
