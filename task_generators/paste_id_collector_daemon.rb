#!/usr/bin/env ruby

# paste_id_collector_daemon.rb - the daemon for the paste ID collector
# Author: Ryan Victory

require 'daemons'

Daemons.run(File.join(Dir.pwd, "paste_id_collector.rb"), {:monitor => true, :dir_mode => :script, :dir => '../pids'})