#!/usr/bin/ruby

require 'hipchat'
require 'optparse'
require 'erb'

options = {
  :token => nil,
  :room  => nil,
  :type  => nil,
  :inputs => nil
}

OptionParser.new { |opts|
  opts.on('--token TOKEN') { |t| options[:token] = t }
  opts.on('--room ROOM') { |r| options[:room] = r }
  opts.on('--type TYPE') { |t| options[:type] = t }
  opts.on('--inputs INPUTS') { |i| options[:inputs] = i }
}.parse!(ARGV)

if options.values.any?(&:nil?)
  puts "invalid options: #{options.inspect}"
  exit 1
end

client = HipChat::Client.new(options[:token])
client[options[:room]].send('Nagios', "Test: #{options[:inputs].inspect} | Type: #{options[:type]}")