#!/bin/bash

PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "---------------------------------------------------"
echo "Credenciales ArgoCD UI:"
echo "URL: https://localhost:8081"
echo "Usuario: admin"
echo "Password: $PASS"
echo "---------------------------------------------------"
echo "App Wil: http://localhost:8888"
echo "---------------------------------------------------"

# Este comando mantiene la terminal ocupada para el túnel
kubectl port-forward svc/argocd-server -n argocd 8081:443
