# paste_id_collector.rb : collects paste_ids from PasteBin and pushes them as new tasks to the task server
# Author: Ryan Victory
# Known Issues: none
# TODO: Convert to use the generic_scraper_worker instead of getting its own data

require 'date'
require 'drb/drb'
require 'net/http'
require 'socksify/http'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

task_server = DRbObject.new_with_uri(SERVER_URI)

$tor_server = DRbObject.new_with_uri("druby://localhost:8888")

paste_ids = []

while true do
  tor = $tor_server.get_proxy
  ua = $tor_server.random_ua
  uri = URI.parse("http://pastebin.com/archive")
  begin
    response = Net::HTTP.SOCKSProxy(tor[:address], tor[:port]).start(uri.host, uri.port) do |http|
      http.get(uri.path,  {'User-Agent' => ua})
    end
  rescue
    puts "Well, something went wrong, we are probably blocked #{$!}"
    $tor_server.cycle_proxy(tor)
    Kernel.sleep 5
    next
  end
  pattern = /<a href="\/([a-zA-Z0-9]{8})">([^>]+)<\/a>/
  response.body.scan(pattern).each do |x|
    unless paste_ids.include? x[0]
      task_server.push_task("waiting_for_content", {:paste_id => x[0], :title => x[1], :ts => DateTime.now.to_s})
      paste_ids.push x[0]
    end
  end

  if paste_ids.length >= 200
    #Delete the first 100 paste_ids in the list
    paste_ids.slice!(0..100)
  end

  Kernel.sleep 15
end