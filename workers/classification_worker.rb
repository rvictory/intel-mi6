# classification_worker.rb : connects to the task server and grabs items that need to be classified
# Author: Ryan Victory
# Known Issues: none
# TODO: read search rules from the database
# TODO: reload search rules on signal (SIGUSR1)
# TODO: bayesian classification or similar?
# TODO: reload bayesian training data on signal (SIGUSR2)
# TODO: create DSL for auto classification/deleting

require 'drb'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
DRb.start_service

$task_server = DRbObject.new_with_uri(SERVER_URI)

def process_task(task)
  # We are not going to classify right now, simply construct a new document and push to the persist queue
  document = {
      :database => 'intel',
      :collection => 'intel_items',
      :document => task
  }
  $task_server.push_task('persist', document)
end

while true do
  #Check to see if there's a task
  task = $task_server.get_task("classify")
  process_task(task) unless task.nil?
  sleep 2 if task.nil?
end