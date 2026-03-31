#!/bin/bash
sudo apt-get update -y
sudo apt-get install curl -y

export INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --bind-address=192.168.56.110 --node-ip=192.168.56.110"

# Instalación de K3s Server
curl -sfL https://get.k3s.io | sh -

# Copiar el token a la carpeta compartida para que el Worker lo pueda leer
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
