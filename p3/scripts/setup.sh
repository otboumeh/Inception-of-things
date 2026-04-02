#!/bin/bash

# 1. Instalación de herramientas base
sudo apt-get update -y
sudo apt-get install -y curl wget git docker.io
sudo usermod -aG docker $USER

# 2. Instalación de Kubectl, K3d y ArgoCD CLI
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Instalar K3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Instalar ArgoCD CLI (Obligatorio para el paso 5)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# 3. Limpiar clústeres anteriores y crear el nuevo
echo "Limpiando clústeres K3d existentes..."
k3d cluster delete --all

echo "Creando nuevo clúster..."
k3d cluster create iot-cluster -p "8888:8888@loadbalancer" -p "8080:80@loadbalancer"
kubectl create namespace argocd
kubectl create namespace dev

# 4. Instalar ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side

echo "Esperando a que los contenedores de ArgoCD se inicien..."
sleep 20 # Subimos un poco el sleep para asegurar que los Pods ya existen antes de hacerles wait
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# 5. Configurar la aplicación via CLI (Usando un túnel temporal interno)
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &
PF_PID=$!
sleep 10 # Damos un poco más de tiempo para que el túnel se establezca bien

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Iniciar sesión en ArgoCD
argocd login localhost:8081 --username admin --password $ARGOCD_PASSWORD --insecure

# Crear la aplicación
argocd app create wil-playground-app \
    --repo https://github.com/otboumeh/eandres.git \
    --path . \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev \
    --sync-policy automated \
    --auto-prune \
    --self-heal

# Cerrar el túnel temporal
kill $PF_PID

echo "Configuración inicial completa. Usa scripts/access.sh para entrar."
