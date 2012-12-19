# cycle_tor.rb - Used to change the identity on the specified tor instance
#                External script was necessary to get around some random dRb issues
# Author: Ryan Victory
# Usage: ruby cycle_tor.rb CONTROL_PORT PASSWORD

require 'socket'

puts "Error, wrong number of args" if ARGV.length < 2

control_port = ARGV[0]
password = ARGV[1]

s = TCPSocket.open('localhost', control_port)
s.puts "AUTHENTICATE \"#{password}\""
# The signal that tells the tor controller to get a new route/identity
s.puts "SIGNAL NEWNYM"
s.close