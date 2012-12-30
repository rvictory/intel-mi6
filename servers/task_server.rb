# task_server.rb : provides a dRb server to create queues with tasks
# Author: Ryan Victory
# Known Issues: none
# TODO: Write tasks to disk in case of failure?
# TODO: Clustered task servers?
# Note: WHY AM I REPLICATING RABBIT-MQ? Because I can. Rabbit may be the direction I go in the future, but for now I'm
#       trying to see what I can accomplish with dRb, in theory it's more portable this way.
#       A future idea is to allow certain workers to be run on Android devices that can run ruby (using
#       Ruboto), and by having the task server be in pure ruby I avoid any issues with loading the Rabbit or AMQP gem
#       onto the device.

require 'drb/drb'

# The URI for the clients to connect to
URI="druby://0.0.0.0:8787"

# TaskServer - Provides mechanisms for adding tasks and getting tasks
class TaskServer

  def initialize
    # Hash to represent the queues
    @queues = {}
    @awaiting_ack = {}
    @current_id = 0
    # Hash to represent the tasks that have been un-acknowledged
  end

  # push_task - Adds a task to the stack
  #   queue: the name of the queue
  #   task: a task
  def push_task(queue, task)
    @queues[queue] = [] unless @queues.has_key? queue
    puts "Received task: #{task.inspect} on queue #{queue}"
    task[:task_id] = next_id
    @queues[queue].push task
  end

  # get_task - gets a task
  # @param [string] queue - the name of the queue to pull from
  # @param [boolean] await_ack - specifies whether or not this task will be ack'd
  # @return [hash] the task, or nil if there are no tasks
  def get_task(queue, await_ack = false)
    return nil unless @queues.has_key? queue
    return nil if @queues[queue].empty?
    task = @queues[queue].pop
    puts "Sending task: " + task.inspect

    # If the queue is now empty, remove it to save space in the future
    @queues.delete(queue) if @queues[queue].empty?

    # If we are going to wait for the task to be ack'd, add it to the awaiting_ack queue
    if await_ack
      # Create the awaiting ack hash if it's not already there
      @awaiting_ack[queue] = {} unless @awaiting_ack.has_key? queue
      @awaiting_ack[queue][task[:task_id]] = task
    end

    task
  end

  # ack_task - acknowledge a task
  # @param [string] queue - the name of the queue
  # @param [int] task_id - the task_id to acknowledge
  def ack_task queue, task_id
    return unless @awaiting_ack.has_key? queue
    @awaiting_ack[queue].delete task_id
  end

  # nack_task - return the task to the queue (something went wrong)
  # @param [string] queue - the name of the queue
  # @param [int] task_id - the task_id of the task to nack
  def nack_task queue, task_id
    return unless @awaiting_ack.has_key? queue
    task = @awaiting_ack[queue].delete task_id
    push_task(queue, task) if task
  end

  def stats
    stats = @queues.each_key.inject("") do |output, queue|
      output = output + "Queue #{queue} has #{@queues[queue].length} messages\n"
    end
    stats
  end

  # next_id - returns the next task ID
  def next_id
    @current_id = @current_id + 1
    @current_id
  end

  private :next_id

end

# The object that handles requests on the server
FRONT_OBJECT = TaskServer.new

$SAFE = 1   # disable eval() and friends

DRb.start_service(URI, FRONT_OBJECT)
DRb.thread.join