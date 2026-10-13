#!/usr/bin/env bash
set -euo pipefail

# Bare-metal 학습 클러스터용 NGINX Ingress Controller 제거
# 설치 스크립트와 동일한 공식 manifest를 사용해 Controller 관련 리소스만 삭제한다.
# 애플리케이션 Namespace의 Ingress 리소스는 이 스크립트가 삭제하지 않는다.
INGRESS_NGINX_VERSION="${INGRESS_NGINX_VERSION:-v1.15.1}"
MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${INGRESS_NGINX_VERSION}/deploy/static/provider/baremetal/deploy.yaml"

echo "Removing NGINX Ingress Controller (${INGRESS_NGINX_VERSION})..."
kubectl delete --ignore-not-found -f "${MANIFEST_URL}"

echo "Verifying removal..."
kubectl get namespace ingress-nginx --ignore-not-found
kubectl get ingressclass nginx --ignore-not-found
kubectl -n ingress-nginx get deployment ingress-nginx-controller --ignore-not-found
