# file_persistence_worker.rb - listens to the "persist" queue and writes the contents to a file
# Author: Ryan Victory
# Known Issues: none
#

require 'drb'
require 'date'

PATH = "/mapr/cluster.raptor.beer/pastebin/"
#PATH = "/Users/rvictory/pastebin/"

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$task_server = DRbObject.new_with_uri(SERVER_URI)
# I'm using a replica set, change this if you only have one mongo instance (shame on you!)
#$mongo_connection = ReplSetConnection.new(['10.0.0.200:27017', 'mongoose2:27017', 'mongoose3:27017'], :read => :secondary)

def process_task(task)
  puts task.inspect
  directory = Date.today.to_s
  Dir.mkdir(PATH + directory) unless File.exists?(PATH + directory)

  begin
    File.open(File.join(PATH + directory, task[:paste_id]), 'w') { |file| file.write(task[:data]) }
  rescue
    # If, for whatever reason, there's an error, shoot the document back to the task server
    puts "Error #{$!}"
    $task_server.push_task('persist', task)
  end


end

while true do
  #Check to see if there's a task
  task = $task_server.get_task("persist")
  process_task(task) unless task.nil?
  sleep 2 if task.nil?
end