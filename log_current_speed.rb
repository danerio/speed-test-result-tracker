#!/usr/bin/env ruby
require 'bundler'
Bundler.require
require 'Date'
require 'json'

# CRON: */15 * * * * cd /Users/danella/Documents/Projects/usage-monitor && bundle exec ruby log_current_speed.rb
# https://www.twilio.com/blog/2017/03/google-spreadsheets-ruby.html

def run_speed_test
  results_as_string = `/usr/local/bin/speedtest-cli --json --share`

  results = JSON.parse(results_as_string)

  formatted_host = "#{results["server"]["sponsor"]} (#{results["server"]["name"]}) [#{results["server"]["d"].round(2)} km]"
  
  {
    :up => bits_to_megabits(results["upload"]),
    :down => bits_to_megabits(results["download"]),
    :host => formatted_host,
    :provider => results["client"]["isp"],
    :ip => results["client"]["ip"],
    :ping => results["ping"],
    :share => results['share'],
    :raw => results_as_string
  }
end

def bits_to_megabits (bits)
  (bits.to_f / 1000000).round(2)
end

def log_current_speed
  run_at = Time.now.getutc
  results = run_speed_test
  completed_at = Time.now.getutc
  run_time = completed_at - run_at

  session = GoogleDrive::Session.from_service_account_key("client_secret.json")
  spreadsheet = session.spreadsheet_by_title("Speed Test Results")
  worksheet = spreadsheet.worksheets.first

  worksheet.insert_rows(2, [
    [
      run_at,
      results[:down],
      results[:up],
      results[:provider],
      results[:ip],
      results[:ping],
      results[:host],
      run_time,
      results[:share],
      results[:raw],
  ]])
  worksheet.save
end
