#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - \
	--disable metrics-server \
	--disable local-storage \
	--node-ip 192.168.56.110

sleep 10

alias k='/usr/local/bin/kubectl'

# /usr/local/bin/kubectl apply -f /vagrant/confs/
