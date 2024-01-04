#!/usr/bin/env ruby

require './log_current_speed.rb'

desc "Log current network speeds."
task :default => [:log_speed]

task :log_speed do
  ruby "log_current_speed.rb"
  log_current_speed
end
