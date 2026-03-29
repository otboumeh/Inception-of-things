#!/bin/bash

curl -sfL https://get.k3s.io | sh -

sleep 10

alias k='/usr/local/bin/kubectl'

# /usr/local/bin/kubectl apply -f /vagrant/confs/
