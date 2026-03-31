#!/bin/bash
sudo apt-get update -y
sudo apt-get install curl -y

# Esperar a que el archivo del token aparezca en la carpeta compartida
while [ ! -f /vagrant/node-token ]; do
  sleep 2
done

export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN=$(cat /vagrant/node-token)
export INSTALL_K3S_EXEC="--node-ip=192.168.56.111"

# Instalación de K3s Agent (Worker)
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -
