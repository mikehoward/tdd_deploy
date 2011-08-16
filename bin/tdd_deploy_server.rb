$:.unshift File.expand_path('../lib', __FILE__)
CONFIG_RU = File.expand.path('../config.ru', __FILE__)

system "rackup #{CONFIG_RU}"
