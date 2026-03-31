#!/bin/bash
sudo apt-get update -y
sudo apt-get install curl net-tools -y

while [ ! -f /vagrant/node-token ]; do
  sleep 2
done

# Leemos el token de forma segura con sudo
export K3S_TOKEN=$(sudo cat /vagrant/node-token)
export K3S_URL="https://192.168.56.110:6443"

# Añadimos --flannel-iface=eth1
export INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=eth1"

curl -sfL https://get.k3s.io | sh -
