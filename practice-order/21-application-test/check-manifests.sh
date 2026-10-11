#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
kubectl apply --dry-run=client -f practice-order/10-3tier/frontend.yml >/dev/null
kubectl apply --dry-run=client -f practice-order/10-3tier/backend.yml >/dev/null
echo "practice manifests are valid"
