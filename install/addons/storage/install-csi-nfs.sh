#!/usr/bin/env bash
set -euo pipefail

# NFS CSI Driver를 kube-system이 아닌 전용 Namespace에 설치한다.
version="${CSI_NFS_VERSION:-v4.13.4}"
namespace="${CSI_NFS_NAMESPACE:-csi-nfs}"
base_url="https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/${version}/deploy/${version}"

command -v kubectl >/dev/null
command -v curl >/dev/null

kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -

for manifest in \
  rbac-csi-nfs.yaml \
  csi-nfs-driverinfo.yaml \
  csi-nfs-controller.yaml \
  csi-nfs-node.yaml; do
  curl -fsSL "$base_url/$manifest" \
    | sed "s/namespace: kube-system/namespace: $namespace/g" \
    | kubectl apply -f -
done

kubectl -n "$namespace" rollout status deployment/csi-nfs-controller --timeout=180s
kubectl -n "$namespace" rollout status daemonset/csi-nfs-node --timeout=180s
kubectl get csidriver nfs.csi.k8s.io
