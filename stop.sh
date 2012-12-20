#!/bin/bash

# This file will control stopping the system
cd servers
./task_server_daemon.rb stop
./tor_server_daemon.rb stop
cd ..

# Here are the task generators (pastebin only for now)
cd task_generators
./paste_id_collector_daemon.rb stop
cd ..

# Workers
cd workers
./paste_content_worker_daemon.rb stop
./classification_worker_daemon.rb stop
./mongo_persistence_worker_daemon.rb stop