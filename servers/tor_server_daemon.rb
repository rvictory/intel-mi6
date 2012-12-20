#!/usr/bin/env ruby

# tor_server_daemon.rb - the daemon for the tor server
# Author: Ryan Victory

require 'daemons'

# This one is interesting, we are going to pass the current dir to the tor server to make sure it can talk to its tor
# working dirs

Daemons.run(File.join(Dir.pwd, "tor_server.rb"), {:ARGV => [ARGV.join(" "), '--', Dir.pwd], :log_output => true, :monitor => true, :dir_mode => :script, :dir => '../pids'})