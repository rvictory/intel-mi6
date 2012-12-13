require 'date'
require 'drb/drb'
require 'net/http'
require 'socksify/http'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

task_server = DRbObject.new_with_uri(SERVER_URI)

paste_ids = []

while true do
  uri = URI.parse("http://pastebin.com/archive")
  begin
    response = Net::HTTP.SOCKSProxy("127.0.0.1", 9050).start(uri.host, uri.port) do |http|
      http.get(uri.path,  {'User-Agent' => 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)'})
    end
  rescue
    puts "Well, something went wrong, we are probably blocked #{$!}"
    Kernel.sleep 5
    next
  end
  pattern = /<a href="\/([a-zA-Z0-9]{8})">([a-zA-Z0-9]{8})<\/a>/
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