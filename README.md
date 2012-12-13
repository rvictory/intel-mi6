intel-mi6
==============
*Like James Bond for your text based intelligence*

intel-mi6 is a ruby script library for scraping pastebin (for now) and other intel sources.

The system relies on distributed ruby to setup a task server (similar to Rabbit MQ), and a Tor Proxy server manager (this will eventually handle the tor proxies).

Workers (which can be on any machine) connect to the servers to get tasks and process them. There is a paste id collector that grabs paste ids from pastebin, a paste contents collector that scrapes the contents, and eventually a classification/persistence worker.

This project is the fourth iteration of my pastebin scraper, it started as two perl scripts, morphed into my inaugural ruby project, was then rewritten again, and here it is, now distributed and awesome.

MongoDB will eventually provide the persistence.