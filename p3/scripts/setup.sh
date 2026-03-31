#!/bin/bash

# 1. Instalación de herramientas
sudo apt-get update -y
sudo apt-get install -y curl wget git docker.io
sudo usermod -aG docker $USER

# 2. Instalación de Kubectl y K3d
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 3. Crear cluster (Puerto 8888 para la app y 8080 para el tráfico general)
k3d cluster create iot-cluster -p "8888:8888@loadbalancer" -p "8080:80@loadbalancer"
kubectl create namespace argocd
kubectl create namespace dev

# 4. Instalar ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side
echo "Esperando a ArgoCD..."
sleep 15
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# 5. Configurar la aplicación via CLI (Usando un túnel temporal interno)
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &
PF_PID=$!
sleep 5

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8081 --username admin --password $ARGOCD_PASSWORD --insecure

argocd app create wil-playground-app \
    --repo https://github.com/otboumeh/eandres.git \
    --path . \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev \
    --sync-policy automated \
    --auto-prune \
    --self-heal

kill $PF_PID
echo "Configuración inicial completa. Usa scripts/access.sh para entrar."
