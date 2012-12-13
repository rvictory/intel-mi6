require 'drb/drb'

# The URI to connect to
SERVER_URI="druby://localhost:8888"

# Start a local DRbServer to handle callbacks.
#
# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.
DRb.start_service

tor = DRbObject.new_with_uri(SERVER_URI)

puts tor.make_request("http://canihazip.com")