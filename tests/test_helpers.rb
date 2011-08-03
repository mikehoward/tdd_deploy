$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib/hosts', __FILE__)
$:.unshift File.expand_path('../lib/sites', __FILE__)

require('test/unit')
