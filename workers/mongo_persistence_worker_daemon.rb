#!/usr/bin/env ruby

# mongo_persistence_worker_daemon.rb - the daemon for the classifier
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "mongo_persistence_worker.rb"), {:multiple => true, :monitor => false, :dir_mode => :script, :dir => '../pids'})