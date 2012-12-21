# generic_scraper_worker.rb - Scrapes html from urls in the "scrape" queue using tor and puts the results onto the next
#                             queue specified (or the "scraped" queue if no queue is specified). Any script that wants
#                             to retrieve HTML from a URL using tor should use this instead of doing its own work.
# Author: Ryan Victory
# Known Issues: None
#
# Expected input document style:
# {:url => "The url that this worker should retrieve", :next_queue => "OPTIONAL: which queue to put the results on"}
# Note: any other key value pairs on the input document will be passed along

require 'net/http'
require 'socksify/http'
require 'drb'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$task_server = DRbObject.new_with_uri(SERVER_URI)

$tor_server = DRbObject.new_with_uri("druby://localhost:8888")

def process_task(task)
  uri = URI.parse(task[:url])
  tor = $tor_server.get_proxy
  ua = $tor_server.random_ua
  begin
    response = Net::HTTP.SOCKSProxy(tor[:address], tor[:port]).start(uri.host, uri.port) do |http|
      http.get(uri.path,  {'User-Agent' => ua})
    end
  rescue
    puts "Something went wrong"
    # Put the task back on the queue
    $task_server.push_task "scrape", task
    return
  end

  task[:contents] = response.body
  next_queue = task[:next_queue] || "scraped"

  $task_server.push_task next_queue, task
end

while true do
  #Check to see if there's a task
  task = $task_server.get_task("scrape")
  process_task(task) unless task.nil?
  sleep 2 if task.nil?
end