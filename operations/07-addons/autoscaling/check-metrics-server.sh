#!/usr/bin/env bash
set -euo pipefail

# APIService가 Available 상태가 될 때까지 잠시 기다린다.
kubectl wait --for=condition=Available \
  apiservice/v1beta1.metrics.k8s.io --timeout=120s
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
