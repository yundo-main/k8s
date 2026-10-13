#!/usr/bin/env bash

# 11-ingress 실습에서 생성한 Ingress 리소스만 삭제한다.
# Ingress Controller, IngressClass, NodePort Service는 삭제하지 않는다.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SCRIPT_DIR}/ingress.yml"

kubectl delete --ignore-not-found -f "${MANIFEST}"
kubectl get ingress fastapi-ingress --ignore-not-found
