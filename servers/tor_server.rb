# tor_server.rb : provides a dRb server to manage the running instances of tor
# Author: Ryan Victory
# Known Issues: It's a work in progress
# TODO: Move configuration to a file/database?

require 'drb/drb'
require 'socket'

trap("EXIT") {
  FRONT_OBJECT.tor_pids.each do |pid|
    puts "Killing #{pid}"
    Process.kill("INT", pid)
  end
  exit
}

at_exit do
  FRONT_OBJECT.tor_pids.each do |pid|
    puts "Killing #{pid}"
    Process.kill("INT", pid)
  end
end

# In order to handle being daemonized, we are going to immediately check for a argument and chdir to that if there is one

if ARGV.length > 0
  Dir.chdir(ARGV[0])
end

# The URI for the clients to connect to
SERVER_URI="druby://0.0.0.0:8888"

class TorServer

  # random_ua: returns a random user agent from a list of pre-programmed UAs
  #   returns: a user-agent string to use
  def random_ua
    uas = [
        'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
        'Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.0) Opera 7.02 Bork-edition [en]',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; FunWebProducts; .NET CLR 1.1.4322; PeoplePal 6.2)',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; MRA 5.8 (build 4157); .NET CLR 2.0.50727; AskTbPTV/5.11.3.15590)',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) )',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322)',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
        'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 3.5.30729)',
        'Mozilla/5.0 (Linux; U; Android 2.2; fr-fr; Desire_A8181 Build/FRF91) App3leWebKit/53.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1',
        'Mozilla/5.0 (Windows NT 5.1; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1',
        'Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1',
        'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1',
        'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0',
        'Mozilla/5.0 (Windows NT 6.1; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (Windows NT 6.1; rv:2.0b7pre) Gecko/20100921 Firefox/4.0b7pre',
        'Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.02',
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
        'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0',
        'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)',
        'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
        'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25',
        'Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.289 Version/12.01'
    ]
    uas.shuffle.first
  end

  def tor_pids
    @proxies.map {|x| x[:pid]}
  end

  def initialize(num_proxies)

    #Configuration - Edit these values as you see fit
    @tor_password = "Ruby Intel Engine"
    # tor --hash-password "Ruby Intel Engine"
    @tor_hash = "16:9109C0EF5A8FA98660943BAAB39C71B18CDD49FE43D43914B24F94B6B1"
    @tor_executable = "/Applications/Vidalia.app/Contents/MacOS/tor" # This is the Mac OS tor installed with Vidalia

    @proxies = []

    start_proxies(num_proxies)
  end

  def get_proxy
    @proxies.shuffle().first
  end

  # cycle_proxy: changes the public IP for the proxy
  #   tor_hash: a tor hash that contains the information to cycle (received from get_proxy)
  #   Returns: nothing. Callers should assume that the proxy they sent is now cycled
  def cycle_proxy tor_hash
      begin
        control_port = tor_hash[:port] + 1000
        spawn("ruby cycle_tor.rb #{control_port} \"#{@tor_password}\"")
      rescue
        # There was an error of some sort, let's just bounce the instance
        puts "Error! #{$!}"
        restart_tor_instance(tor_hash)
      end
  end

  # Restarts the specified tor instance
  #   tor_hash: the tor hash containing the the information to restart the process
  #   Returns: nothing, but the specified tor instance should be assumed to be restarted
  def restart_tor_instance(tor_hash)
    @proxies.delete_if {|x| x[:port] == tor_hash[:port]}
    start_proxy(tor_hash[:port], tor_hash[:port] + 1000, tor_hash[:data_dir])
  end

  # Starts the specified number of tor proxies, adding them to the proxy list
  #   num_proxies: the number of proxies to start
  def start_proxies(num_proxies)
    0.upto(num_proxies - 1) do |x|
      port = 9050 + x
      control_port = port + 1000
      datadir = "#{Dir.pwd}/tor/tor#{x}"
      start_proxy(port, control_port, datadir)
    end
  end

  # Starts the specified proxy
  #   port: the port to use for the tor instance
  #   control_port: the control port to use (in MI-6, this is socks_port + 1000)
  #   datadir: the data directory that this instance should use
  def start_proxy(port, control_port, datadir)
    pid = Process.spawn("#{@tor_executable} --SocksPort #{port} --quiet --DataDirectory #{datadir} --ControlPort #{control_port} --HashedControlPassword \"#{@tor_hash}\"")
    @proxies.push ({:pid => pid, :port => port, :address => 'localhost', :data_dir => datadir}) #TODO: Change to the actual host
  end

end


# The object that handles requests on the server
FRONT_OBJECT = TorServer.new(20)

$SAFE = 1   # disable eval() and friends

DRb.start_service(SERVER_URI, FRONT_OBJECT)
# Wait for the drb server thread to finish before exiting.
DRb.thread.join