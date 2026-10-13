#!/usr/bin/env bash
set -euo pipefail

# Calico CNI 제거
# 주의: 클러스터 Pod 네트워크가 중단될 수 있으므로 실습 종료 후에만 실행한다.
CALICO_VERSION="${CALICO_VERSION:-v3.33.0}"
MANIFEST_URL="https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"

echo "Removing Calico CNI (${CALICO_VERSION})..."
kubectl delete --ignore-not-found -f "${MANIFEST_URL}"

echo "Verifying removal..."
kubectl -n calico-system get pods --ignore-not-found
kubectl get daemonset calico-node -n calico-system --ignore-not-found
