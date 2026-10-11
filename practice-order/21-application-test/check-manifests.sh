#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null
kubectl apply --dry-run=client -f k8s/practice-order/10-3tier/frontend.yml >/dev/null
kubectl apply --dry-run=client -f k8s/practice-order/10-3tier/backend.yml >/dev/null
echo "practice manifests are valid"

