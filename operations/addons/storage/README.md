# Storage Controller

PersistentVolumeClaim 요청에 따라 스토리지를 동적으로 생성하거나 연결한다.

일반적으로 CSI Driver와 StorageClass를 함께 관리한다.

## NFS CSI Driver

이 실습은 `nfs-server` Pod를 NFS 서버로 사용하고, NFS CSI Driver가
`nfs.csi.k8s.io` StorageClass의 PVC 요청을 처리하도록 구성한다.

현재 08번 실습은 ARM64·AMD64를 지원하는
`andrewkidd/nfs-server:v2.2.7` 이미지를 사용한다. 이 이미지는 노드의 NFS
커널 모듈(`nfs`, `nfsd`)을 필요로 하므로 실습 전
[`nfs-kernel-modules.yml`](../../../practice-order/08-storage/nfs-kernel-modules.yml)을
적용한다.

NFS CSI Driver를 설치한 뒤 다음 상태를 확인한다.

```bash
ansible-playbook -i install/inventory/hosts.yml \
  install/playbooks/addons/nfs-csi.yml

kubectl -n csi-nfs get pod -l app=csi-nfs-controller
kubectl -n csi-nfs get pod -l app=csi-nfs-node
kubectl get csidriver nfs.csi.k8s.io
```

설치 스크립트는 공식 v4.13.4 manifest의 `kube-system` Namespace 참조를
`csi-nfs`로 바꿔 적용한다. Controller·Node Plugin은 `csi-nfs`에 배치되지만
`CSIDriver`, ClusterRole, ClusterRoleBinding은 클러스터 범위로 생성된다.

삭제할 때는 PVC를 먼저 정리한 뒤 다음 스크립트를 실행한다.

```bash
bash ./install/addons/storage/uninstall-csi-nfs.sh
```

공식 설치 문서:
<https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.13.4.md>

서버 Pod, Service, StorageClass, PVC의 학습 순서는
[`practice-order/08-storage`](../../../practice-order/08-storage/README.md)를 따른다.

> NFS 서버 Pod는 테스트용 구성이다. `hostPath`를 사용하므로 운영 환경에서는
> 별도의 고가용성 NFS 서버 또는 관리형 스토리지를 사용한다.
