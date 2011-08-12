Dir.new(File.expand_path('../host_tests', __FILE__)).each do |fname|
  require "tdd_deploy/host_tests/#{File.basename fname, '.rb'}"
end

