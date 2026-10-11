# Storage Controller

PersistentVolumeClaim 요청에 따라 스토리지를 동적으로 생성하거나 연결한다.

일반적으로 CSI Driver와 StorageClass를 함께 관리한다.

## NFS CSI Driver

이 실습은 `nfs-server` Pod를 NFS 서버로 사용하고, NFS CSI Driver가
`nfs.csi.k8s.io` StorageClass의 PVC 요청을 처리하도록 구성한다.

NFS CSI Driver를 설치한 뒤 다음 상태를 확인한다.

```bash
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.13.4/deploy/install-driver.sh \
  | bash -s v4.13.4 --

kubectl -n kube-system get pod -l app=csi-nfs-controller
kubectl -n kube-system get pod -l app=csi-nfs-node
kubectl get csidriver nfs.csi.k8s.io
```

공식 설치 문서:
<https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.13.4.md>

서버 Pod, Service, StorageClass, PVC의 학습 순서는
[`practice-order/08-storage`](../../practice-order/08-storage/README.md)를 따른다.

> NFS 서버 Pod는 테스트용 구성이다. `hostPath`를 사용하므로 운영 환경에서는
> 별도의 고가용성 NFS 서버 또는 관리형 스토리지를 사용한다.
