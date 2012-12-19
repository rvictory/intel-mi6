# paste_content_worker.rb : connects to the dRb task server to grab paste collection tasks, gets their contents and
#                           pushes the contents to the classify queue
# Author: Ryan Victory
# Known Issues: none

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
  puts task.inspect
  uri = URI.parse("http://pastebin.com/" + task[:paste_id])
  tor = $tor_server.get_proxy
  ua = $tor_server.random_ua
  begin
    response = Net::HTTP.SOCKSProxy(tor[:address], tor[:port]).start(uri.host, uri.port) do |http|
      http.get(uri.path,  {'User-Agent' => ua})
    end
  rescue
    puts "Something went wrong, we might be blocked. Waiting for the other script to retry"
    # Tell the tor server to bounce the instance
    $tor_server.cycle_proxy(tor)
    # Return the task to the server
    $task_server.push_task "waiting_for_content", task
    return
  end
  if response.body =~ /Hey, it seems you are requesting a little bit too much from Pastebin. Please slow down!/ || response.body =~ /Pastebin.com - Heavy Load Warning/
    puts 'we are over the limit, waiting 10 seconds'
    Kernel.sleep 10
    $task_server.push_task "waiting_for_content", task
  end
  if response.body =~ /Pastebin.com Unknown Paste ID/ || response.body =~ /Private Paste ID:/
    puts "Unknown Paste Deleting"
    return #We just don't do anything with it
  end
  pattern = /<textarea[^>]*>([^<]*)<\/textarea>/
  response.body.scan(pattern).each do |x|
    task[:data] = x[0].encode!( 'UTF-8', invalid: :replace, undef: :replace )
  end
  pattern = /<title>([^<]*)<\/title>/
  response.body.scan(pattern).each do |x|
    task[:title] = x[0].gsub(' - Pastebin.com', '').encode!( 'UTF-8', invalid: :replace, undef: :replace )
    puts x[0]
  end
  # Forward off the new message to the "classifier" queue
  $task_server.push_task "classify", task
end

while true do
  #Check to see if there's a task
  task = $task_server.get_task("waiting_for_content")
  process_task(task) unless task.nil?
  sleep 2 if task.nil?
end