#!/usr/bin/env ruby

# task_server_daemon.rb - the daemon for the task server
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "task_server.rb"), {:monitor => true, :dir_mode => :script, :dir => '../pids'})