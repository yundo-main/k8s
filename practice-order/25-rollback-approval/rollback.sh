#!/usr/bin/env bash
set -euo pipefail
kubectl rollout history deployment/fastcgi-backend
read -r -p "Rollback fastcgi-backend? [y/N] " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  kubectl rollout undo deployment/fastcgi-backend
  kubectl rollout status deployment/fastcgi-backend --timeout=180s
fi

