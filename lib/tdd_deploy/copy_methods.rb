require 'net/ssh'
require 'net/sftp'
require 'fileutils'

module TddDeploy
  module CopyMethods
    def copy_string_to_remote_file_on_hosts_as userid, host_list, str, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= copy_string_to_remote_file_as userid, host, str, dst
      end
      result
    end

    def copy_file_to_remote_hosts_as userid, host_list, src, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= copy_file_to_remote_as userid, host, src, dst
      end
      result
    end

    def copy_dir_to_remote_hosts_as(userid, host_list, src_dir, dest_dir)
      raise ::ArgumentError.new("copy_dir_to_remote_hosts_as: src_dir does not exist: #{src_dir}") \
          unless File.directory? src_dir
      host_list = [host_list] if host_list.is_a? String
      result = true
      host_list.uniq.each do |host|
        result &= mkdir_on_remote_as userid, host, dest_dir
      end
      Dir.open(src_dir).each do |fname|
        next if fname[0] == '.'
        path = File.join(src_dir, fname)
        result &= copy_file_to_remote_hosts_as userid, host_list, path, File.join(dest_dir, fname)
      end
      result
    end
    
    def append_string_to_remote_file_on_hosts_as userid, host_list, str, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= append_string_to_remote_file_as userid, host, str, dst
      end
      result
    end

    def append_file_to_remote_hosts_as userid, host_list, src, dst
      result = true
      host_list = [host_list] if host_list.is_a? String
      host_list.uniq.each do |host|
        result &= append_file_to_remote_file_as userid, host, src, dst
      end
      result
    end

    def append_dir_to_remote_hosts_as(userid, host_list, src_dir, dest_dir)
      raise ::ArgumentError.new("append_dir_to_remote_hosts_as: src_dir does not exist: #{src_dir}") \
          unless File.directory? src_dir
      host_list = [host_list] if host_list.is_a? String
      result = true
      host_list.uniq.each do |host|
        result &= mkdir_on_remote_as userid, host, dest_dir
      end
      Dir.open(src_dir).each do |fname|
        next if fname[0] == '.'
        path = File.join(src_dir, fname)
        result &= append_file_to_remote_hosts_as userid, host_list, path, File.join(dest_dir, fname)
      end
      result
    end

    #single host methods
    
    # options are passed to Net::SFTP process. :permissions default to 0755
    def mkdir_on_remote_as userid, host, dir, options = {}
      result = nil
      options[:permissions] = 0755 unless options.include? :permissions
      Net::SFTP.start(host, userid) do |sftp|
        begin
          result = sftp.opendir! dir
        rescue ::Net::SFTP::StatusException
          result = sftp.mkdir dir, options
        end
      end
      result
    end

    def append_string_to_remote_file_as userid, host, str, dst
      result = nil
      Net::SFTP.start(host, userid) do |sftp|
        if handle = sftp.open!(dst, 'a+')
          stat_buf = sftp.fstat! handle
          result = sftp.write handle, stat_buf.size, str
          sftp.close! handle
        end
      end
      ! result.nil?
    end

    def copy_string_to_remote_file_as userid, host, str, dst
      result = nil
      Net::SFTP.start(host, userid) do |sftp|
        result = sftp.file.open(dst, 'w')  do |f|
          f.write str
        end
      end
      ! result.nil?
    end

    def append_file_to_remote_file_as(userid, host, src, dst)
      raise ::ArgumentError.new("file name cannot be empty") if src.empty?
      raise ::RuntimeError.new("unable to copy #{src} to #{userid}@#{host}: #{src} not found") unless File.exists? src

      f = File.new(src)
      file_mode = f.stat.mode & 0777
      
      if (result = append_string_to_remote_file_as(userid, host, f.read, dst))
        stdout, stderr, cmd = run_on_a_host_as(userid, host, "chmod 0#{sprintf('%o', file_mode)} #{dst}")
        result &= stderr.nil?
      end
      result
    end

    def copy_file_to_remote_as(userid, host, src, dst)
      raise ::ArgumentError.new("file name cannot be empty") if src.empty?
      raise ::RuntimeError.new("unable to copy #{src} to #{userid}@#{host}: #{src} not found") unless File.exists? src
      
      f = File.new(src)
      file_mode = f.stat.mode & 0777

      if (result = copy_string_to_remote_file_as(userid, host, f.read, dst))
        stdout, stderr, cmd = run_on_a_host_as(userid, host, "chmod 0#{sprintf('%o', file_mode)} #{dst}")
        result &= stderr.nil?
      end
      result
    end
  end
end
