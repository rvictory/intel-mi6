# tor_test_worker.rb : connects to the tor server and makes sure it all works
# Author: Ryan Victory
# Known Issues: none

require 'drb'
require 'socksify/http'

# The URI to connect to
SERVER_URI="druby://localhost:8888"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$tor_server = DRbObject.new_with_uri(SERVER_URI)

while true do
  #Check to see if there's a task
  tor = $tor_server.get_proxy
  ua = $tor_server.random_ua
  uri = URI.parse("http://icanhazip.com/")
  puts "Testing tor: #{tor.inspect}"
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
  begin
    $tor_server.cycle_proxy(tor)
  rescue
    puts "Error! #{$!}"
  end
  puts "IP: #{response.body}"
  sleep 5
end