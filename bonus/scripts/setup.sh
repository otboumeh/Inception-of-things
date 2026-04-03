#!/bin/bash

# 1. Instalación de herramientas base (Basado en la Parte 3)
echo "Instalando herramientas base..."
sudo apt-get update -y
sudo apt-get install -y curl wget git docker.io
sudo usermod -aG docker $USER

# Instalar Helm (Necesario para instalar GitLab de forma sencilla)
echo "Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Instalar Kubectl y K3d (Versiones estables)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 2. Configuración del Clúster para el Bonus
echo "Limpiando clústeres anteriores..."
k3d cluster delete --all

echo "Creando clúster iot-bonus con recursos para GitLab..."
# Mapeamos 8082 para GitLab, 8080 para Ingress general y 8888 para la App Wil
# Añadimos 2 agentes para repartir la carga de GitLab
k3d cluster create iot-bonus \
    -p "8888:8888@loadbalancer" \
    -p "8080:80@loadbalancer" \
    -p "8082:80@loadbalancer" \
    --agents 2

# 3. Creación de Namespaces obligatorios
echo "Creando namespaces: argocd, gitlab, dev..."
kubectl create namespace argocd
kubectl create namespace gitlab
kubectl create namespace dev

# 4. Instalación de ArgoCD (Solución al error 'Too long')
echo "Instalando ArgoCD con server-side apply..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side

echo "Esperando a que los componentes de ArgoCD estén listos..."
# Esperamos a que los pods existan antes de lanzar el wait
until kubectl get pods -n argocd 2>/dev/null | grep -q "argocd-server"; do
    sleep 5
done
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# 5. Instalación de GitLab (Requisito del Bonus)
echo "Instalando GitLab en el clúster (esto puede tardar varios minutos)..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Instalación usando el archivo de configuración ligera que creamos en bonus/confs/
helm install gitlab gitlab/gitlab \
  -n gitlab \
  -f ../confs/values.yaml \
  --set global.hosts.externalIP=127.0.0.1 \
  --timeout 600s

echo "---------------------------------------------------------------"
echo "Configuración del Bonus completada con éxito."
echo "Usa tu script access.sh para obtener las contraseñas y entrar."
echo "Recordatorio: Tu VM debe tener al menos 8GB de RAM para GitLab."
echo "---------------------------------------------------------------"
