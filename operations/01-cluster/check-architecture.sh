#!/usr/bin/env bash
set -euo pipefail

# Kubernetes가 보고하는 모든 노드 아키텍처를 확인한다.
command -v kubectl >/dev/null
command -v docker >/dev/null

node_arches=()
while IFS= read -r arch; do
  node_arches+=("$arch")
done < <(
  kubectl get nodes -o jsonpath='{range .items[*]}{.status.nodeInfo.architecture}{"\n"}{end}' \
    | sort -u
)

if ((${#node_arches[@]} == 0)); then
  echo "No node architecture was found" >&2
  exit 1
fi

echo "Node architectures: ${node_arches[*]}"

# 실습 전에 사용하는 외부 이미지의 multi-architecture 지원 여부를 확인한다.
images=(
  "andrewkidd/nfs-server:v2.2.7"
  "jarrodkim/nginx-test:latest"
  "jarrodkim/fastapi-test:latest"
  "jarrodkim/mariadb-test:latest"
  "mariadb:11"
)

failed=0
for image in "${images[@]}"; do
  echo "Checking $image"
  if ! manifest="$(docker buildx imagetools inspect "$image" 2>&1)"; then
    echo "  unable to inspect image manifest" >&2
    echo "$manifest" >&2
    failed=1
    continue
  fi

  for arch in "${node_arches[@]}"; do
    if grep -q "linux/$arch" <<<"$manifest"; then
      echo "  linux/$arch: OK"
    else
      echo "  linux/$arch: MISSING" >&2
      failed=1
    fi
  done
done

if ((failed)); then
  echo "Architecture preflight failed" >&2
  exit 1
fi

echo "Architecture preflight passed"
