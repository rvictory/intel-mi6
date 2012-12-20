intel-mi6
==============
*Like James Bond for your text based intelligence*

intel-mi6 is a ruby script library for scraping pastebin (for now) and other intel sources.

The system relies on distributed ruby to setup a task server (similar to Rabbit MQ), and a Tor Proxy server manager (this will eventually handle the tor proxies).

Workers (which can be on any machine) connect to the servers to get tasks and process them. There is a paste id collector that grabs paste ids from pastebin, a paste contents collector that scrapes the contents, and eventually a classification/persistence worker.

This project is the fourth iteration of my pastebin scraper, it started as two perl scripts, morphed into my inaugural ruby project, was then rewritten again, and here it is, now distributed and awesome.

MongoDB will eventually provide the persistence.

Instructions for Use
===============

The system is getting closer to being usable, although changes will have to made to match your environment (until a configuration
file is added). The following assumptions are made:

* You have a MongoDB server up and running, and at least for my config it's a replica set (workers/mongo_persistence_worker.rb)
* Tor is installed, make sure to alter the @tor_executable variable in servers/tor_server.rb to match your installation (mine is
based on the tor bundled with Vidalia on Mac OS X, most systems will just have "tor" as the variable)
* There are a few gems that are necessary, I'll be looking into gem dependency tools, but for now check the sources and make sure you
have them installed

Once you have satisfied the requirements, my default setup is just to run the "run.sh" script in the root directory. This will start
up the two servers, start the paste id collector, and finally start a lot of workers (30 copies of the paste_content_worker!).

To stop, run the "stop.sh" script in the base directory, this should stop everything.

Enjoy!