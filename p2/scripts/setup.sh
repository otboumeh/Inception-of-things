#!/bin/bash

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install curl -y

curl -sfL https://get.k3s.io | sh -s - \
	--disable metrics-server \
	--disable local-storage \
	--node-ip 192.168.56.110 --flannel-iface=eth1

sleep 10


/usr/local/bin/kubectl apply -f /vagrant/confs/

