#!/bin/sh
while true
do
#   ref: date --help
    date +'%Y-%m-%d %T Mock daemon is still running' >> /tmp/daemon.log
    sleep 30
done
