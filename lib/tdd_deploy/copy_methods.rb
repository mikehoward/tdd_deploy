require 'net/ssh'
require 'net/sftp'

module TddDeploy
  module RunMethods

    def copy_string_to_remote_file_on_hosts_as userid, host_list, str, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= copy_string_to_remote_file_as userid, host, str, dst
      end
      result
    end

    def copy_file_to_remote_on_hosts_as userid, host_list, src, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= copy_file_to_remote_as userid, host, src, dst
      end
      result
    end

    #single host methods
    
    def mkdir_on_remote_as userid, host, dir, options = {}
      result = nil
      options[:permissions] = 0755 unless options.include? :permissions
      Net::SFTP.start(host, userid) do |sftp|
        result = sftp.mkdir dir, options
      end
      result
    end

    def copy_string_to_remote_file_as userid, host, str, dst
      result = nil
      Net::SFTP.start(host, userid) do |sftp|
        result = sftp.file.open(dst, "w")  do |f|
          f.write str
        end
      end
      result
    end

    def copy_file_to_remote_as(userid, host, src, dst)
      require 'net/sftp'
      raise ArgumentError.new("file name cannot be empty") if src.empty?
      raise RuntimeError.new("unable to copy #{src} to #{userid}@#{host}: #{src} not found") unless File.exists? src
      
      copy_string_to_remote_file_as userid, host, File.new(src).read, dst
    end
  end
end
