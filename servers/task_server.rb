# task_server.rb : provides a dRb server to create queues with tasks
# Author: Ryan Victory
# Known Issues: none
# TODO: Task acknowledgement?
# TODO: Write tasks to disk in case of failure?
# TODO: Clustered task servers?
# Note: WHY AM I REPLICATING RABBIT-MQ? Because I can.

require 'drb/drb'

# The URI for the clients to connect to
URI="druby://0.0.0.0:8787"

# TaskServer - Provides mechanisms for adding tasks and getting tasks
class TaskServer

  def initialize
    # Hash to represent the queues
    @queues = {}
    # Hash to represent the tasks that have been un-acknowledged
  end

  # push_task - Adds a task to the stack
  #   queue: the name of the queue
  #   task: a task
  def push_task(queue, task)
    @queues[queue] = [] unless @queues.has_key? queue
    puts "Received task: #{task.inspect} on queue #{queue}"
    @queues[queue].push task
  end

  # get_task - gets a task
  # returns the task or nil if there are no tasks
  def get_task(queue)
    return nil unless @queues.has_key? queue
    return nil if @queues[queue].empty?
    task = @queues[queue].pop
    puts "Sending task: " + task.inspect
    task
  end

  def stats
    stats = @queues.each_key.inject("") do |output, queue|
      output = output + "Queue #{queue} has #{@queues[queue].length} messages\n"
    end
    stats
  end

end

# The object that handles requests on the server
FRONT_OBJECT = TaskServer.new

$SAFE = 1   # disable eval() and friends

DRb.start_service(URI, FRONT_OBJECT)
DRb.thread.join