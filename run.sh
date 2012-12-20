#!/bin/bash

# This file will control starting up the system
echo "Starting Servers"
cd servers
./task_server_daemon.rb start
./tor_server_daemon.rb start
cd ..

# We need to give the tor server some time to get started, sleep for 30 seconds
echo "Waiting 30 seconds for the tor server to get started"
sleep 30

# Here are the task generators (pastebin only for now)
echo "Starting Task Generators"
cd task_generators
./paste_id_collector_daemon.rb start
cd ..

# Workers (there are a lot of them)
echo "Starting Workers"
cd workers
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start

./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start

./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start
./paste_content_worker_daemon.rb start

./classification_worker_daemon.rb start
./classification_worker_daemon.rb start
./classification_worker_daemon.rb start
./classification_worker_daemon.rb start
./classification_worker_daemon.rb start

./mongo_persistence_worker_daemon.rb start
./mongo_persistence_worker_daemon.rb start
./mongo_persistence_worker_daemon.rb start
./mongo_persistence_worker_daemon.rb start

cd ..