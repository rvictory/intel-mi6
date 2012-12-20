#!/usr/bin/env ruby

# paste_content_worker_daemon.rb - the daemon for the paste content worker
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "paste_content_worker.rb"), {:multiple => true, :monitor => false, :dir_mode => :script, :dir => '../pids'})