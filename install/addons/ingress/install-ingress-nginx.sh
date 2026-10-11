#!/usr/bin/env bash
set -euo pipefail

# Bare-metal 학습 클러스터용 NGINX Ingress Controller 설치
# 공식 NodePort manifest를 사용하고 실습에서 사용할 포트를 고정한다.
INGRESS_NGINX_VERSION="${INGRESS_NGINX_VERSION:-v1.15.1}"
INGRESS_NAMESPACE="${INGRESS_NAMESPACE:-ingress-nginx}"
HTTP_NODE_PORT="${HTTP_NODE_PORT:-30198}"
HTTPS_NODE_PORT="${HTTPS_NODE_PORT:-31476}"
MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${INGRESS_NGINX_VERSION}/deploy/static/provider/baremetal/deploy.yaml"

kubectl apply -f "${MANIFEST_URL}"

kubectl -n "${INGRESS_NAMESPACE}" wait \
  --for=condition=available deployment/ingress-nginx-controller \
  --timeout=180s

kubectl -n "${INGRESS_NAMESPACE}" patch service ingress-nginx-controller \
  --type=json \
  -p="[{\"op\":\"replace\",\"path\":\"/spec/ports/0/nodePort\",\"value\":${HTTP_NODE_PORT}},{\"op\":\"replace\",\"path\":\"/spec/ports/1/nodePort\",\"value\":${HTTPS_NODE_PORT}}]"

kubectl get ingressclass nginx
kubectl -n "${INGRESS_NAMESPACE}" get pods,service ingress-nginx-controller -o wide
