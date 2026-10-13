#!/usr/bin/env bash
set -euo pipefail

# Metrics Server 제거
MANIFEST_URL="${METRICS_SERVER_MANIFEST_URL:-https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml}"

echo "Removing Metrics Server..."
kubectl delete --ignore-not-found -f "${MANIFEST_URL}"

echo "Verifying removal..."
kubectl -n kube-system get deployment metrics-server --ignore-not-found
kubectl get apiservice v1beta1.metrics.k8s.io --ignore-not-found
