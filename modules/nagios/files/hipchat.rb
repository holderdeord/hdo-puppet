#!/usr/bin/env ruby

require 'hipchat' # gem install hipchat
require 'optparse'
require 'erb'

options = {
  :token => nil,
  :room  => nil,
  :type  => nil,
  :inputs => nil
}

colors = {
  'PROBLEM'           =>'red',
  'RECOVERY'          =>'green',
  'ACKNOWLEDGEMENT'   =>'green',
  'FLAPPINGSTART'     =>'yellow',
  'FLAPPINGSTOP'      =>'green',
  'FLAPPINGDISABLED'  =>'gray',
  'DOWNTIMESTART'     =>'red',
  'DOWNTIMESTOP'      =>'green',
  'DOWNTIMECANCELLED' =>'green'
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

case options[:type]
when 'host'
  hostname, long_date_time, notification_type, host_address, host_state, host_output = options[:inputs].split('|')
  msg = "#{hostname} | #{notification_type} | #{host_address} | #{host_state} | #{host_output}"
when 'service'
  service_desc, host_alias, long_date_time, notification_type, host_address, service_state, service_output = options[:inputs].split('|')
  msg = "#{notification_type}: #{service_desc} @ #{host_alias} is #{service_state}: #{service_output}"
else
  exit 1
end

client = HipChat::Client.new(options[:token])
client[options[:room]].send('Nagios', msg, color: colors[notification_type])