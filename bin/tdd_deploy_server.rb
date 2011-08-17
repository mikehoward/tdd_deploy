#! /usr/bin/env ruby

# $:.unshift File.expand_path('../lib', __FILE__)
CONFIG_RU = File.expand_path('../../config.ru', __FILE__)

system "rackup --debug #{CONFIG_RU}"
