#!/usr/bin/env ruby

# file_persistence_worker_daemon.rb - the daemon for the file persistence worker
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "file_persistence_worker.rb"), {:multiple => true, :monitor => false, :dir_mode => :script, :dir => '../pids'})