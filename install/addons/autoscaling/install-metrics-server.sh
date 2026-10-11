#!/usr/bin/env bash
set -euo pipefail

# 실습용 기본값이다. 운영 환경에서는 검증한 버전을 고정한다.
manifest_url="${METRICS_SERVER_MANIFEST_URL:-https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml}"

command -v kubectl >/dev/null
kubectl apply -f "$manifest_url"

# 인증서 검증을 생략하는 옵션은 기본으로 사용하지 않는다.
# 기존 실습 클러스터처럼 kubelet Serving Certificate가 준비되지 않은 경우에만
# 명시적으로 METRICS_SERVER_INSECURE_TLS=true를 지정한다.
if [[ "${METRICS_SERVER_INSECURE_TLS:-false}" == "true" ]]; then
  metrics_args="$(kubectl -n kube-system get deployment metrics-server \
    -o jsonpath='{.spec.template.spec.containers[0].args[*]}')"
  if [[ "$metrics_args" != *"--kubelet-insecure-tls"* ]]; then
    kubectl -n kube-system patch deployment metrics-server \
      --type=json \
      -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
  fi
fi

kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
