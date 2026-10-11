#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:?usage: deploy.sh IMAGE:TAG}"
kubectl apply -f k8s/practice-order/10-3tier/frontend.yml
kubectl apply -f k8s/practice-order/10-3tier/backend.yml
kubectl -n default set image deployment/fastcgi-backend backend="$IMAGE"
kubectl rollout status deployment/fastcgi-backend --timeout=180s

