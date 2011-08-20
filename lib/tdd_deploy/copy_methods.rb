require 'net/ssh'
require 'net/sftp'

module TddDeploy
  module RunMethods
    
    def copy_string_to_remote_file_as userid, host, str, dst
      ssh_session = Net::SSH::Session.new(host, userid)
      raise RuntimeError.new("Cannot open ssh session as #{userid}@#{host}") unless ssh_session
      sftp = Net::SFTP::Session.new(ssh_session )
    end

    def copy_file_to_remote(host, src, dst = nil)
      copy_file_to_remote_as self.host_admin, host, src, dst
    end

    def copy_file_to_remote_as(userid, host, src, dst = nil)
      require 'net/sftp'
      raise ArgumentError.new("file name cannot be empty") if src.empty?
      
      # copy using blocking version
      Net::SFTP.start(host, userid) do |sftp|
        sftp.upload!(src, dst || src)
      end
    end
  end
end
