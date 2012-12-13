# classification_worker.rb : connects to the task server and grabs items that need to be classified
# Author: Ryan Victory
# Known Issues: doesn't do anything

require 'drb'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$task_server = DRbObject.new_with_uri(SERVER_URI)

while true do
  #Check to see if there's a task
  task = $task_server.get_task("classify")
  process_task(task) unless task.nil?
  sleep 5 if task.nil?
end