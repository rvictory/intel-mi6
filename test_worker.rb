require 'drb/drb'

# The URI to connect to
SERVER_URI="druby://localhost:8787"

# Start a local DRbServer to handle callbacks.
#
# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.
DRb.start_service

task_server = DRbObject.new_with_uri(SERVER_URI)

while true do
  task = task_server.get_task
  puts "No tasks for me!" if task.nil?
  puts "Got a task: " + task.inspect unless task.nil?
  sleep 5
end