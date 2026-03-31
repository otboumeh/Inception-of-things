#!/bin/bash
sudo apt-get update -y
sudo apt-get install curl net-tools -y

# Añadimos --flannel-iface=eth1
export INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --bind-address=192.168.56.110 --node-ip=192.168.56.110 --flannel-iface=eth1"

curl -sfL https://get.k3s.io | sh -

# Damos tiempo a que se genere el archivo
sleep 10
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
