# mongo_persistence_worker.rb - listens to the "persist" queue and writes the contents to mongodb
# Author: Ryan Victory
# Known Issues: none
# TODO: configuration file for the mongo connection?
#
# Expected input document format:
# {:database => 'The MongoDB database to use', :collection => 'The collection to use', :document => 'The document to write'}

require 'mongo'
require 'drb'

include Mongo

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$task_server = DRbObject.new_with_uri(SERVER_URI)
# I'm using a replica set, change this if you only have one mongo instance (shame on you!)
$mongo_connection = ReplSetConnection.new(['10.0.0.200:27017', 'mongoose2:27017', 'mongoose3:27017'], :read => :secondary)

def process_task(task)

  begin
    database = task[:database]
    collection = task[:collection]
    document = task[:document]

    $mongo_connection.db(database)[collection].insert(document)

  rescue
    # If, for whatever reason, there's an error, shoot the document back to the task server
    $task_server.push_task('persist', task)
  end


end

while true do
  #Check to see if there's a task
  task = $task_server.get_task("persist")
  process_task(task) unless task.nil?
  sleep 2 if task.nil?
end