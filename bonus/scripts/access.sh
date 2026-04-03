#!/bin/bash

# 1. Extraer contraseñas de los Secretos de Kubernetes
PASS_ARGO=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
PASS_GITLAB=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

echo "---------------------------------------------------"
echo "ARGO CD (Gestor GitOps):"
echo "URL: https://localhost:8081"
echo "Usuario: admin | Password: $PASS_ARGO"
echo "---------------------------------------------------"
echo "GITLAB LOCAL (Servidor Git):"
echo "URL: http://localhost:8082"
echo "Usuario: root | Password: $PASS_GITLAB"
echo "---------------------------------------------------"
echo "App Wil (Producción): http://localhost:8888"
echo "---------------------------------------------------"

# 2. Abrir los túneles (Port-Forward)
# El de ArgoCD se lanza en segundo plano (&) para que el script no se bloquee ahí
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &

# El de GitLab se lanza en primer plano para mantener la terminal activa
echo "Manteniendo túneles activos... Presiona Ctrl+C para salir."
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8082:8181
