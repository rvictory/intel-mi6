#!/usr/bin/env ruby

# classification_worker_daemon.rb - the daemon for the classifier
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "classification_worker.rb"), {:multiple => true, :monitor => false, :dir_mode => :script, :dir => '../pids'})