#!/usr/bin/env bash
set -euo pipefail

version="${CSI_NFS_VERSION:-v4.13.4}"
namespace="${CSI_NFS_NAMESPACE:-csi-nfs}"
base_url="https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/${version}/deploy/${version}"

command -v kubectl >/dev/null
command -v curl >/dev/null

for manifest in \
  csi-nfs-controller.yaml \
  csi-nfs-node.yaml \
  csi-nfs-driverinfo.yaml \
  rbac-csi-nfs.yaml; do
  curl -fsSL "$base_url/$manifest" \
    | sed "s/namespace: kube-system/namespace: $namespace/g" \
    | kubectl delete --ignore-not-found -f -
done

kubectl delete namespace "$namespace" --ignore-not-found --wait=true
