# Persistent Storage

Stateful 애플리케이션의 데이터를 Pod 생명주기와 분리한다.

PV와 PVC의 역할과 연결 흐름은 다음 SVG에서 확인한다.

![PV와 PVC 관계](./pv-pvc-overview.svg)

## NFS Pod 기반 CSI 실습

이 실습은 외부 NFS 서버 대신 테스트용 `nfs-server` Pod를 사용한다. NFS CSI
Driver가 이미 설치되어 있어야 한다.

### 1. NFS CSI Driver 확인

공식 CSI Driver 설치 방법은
[NFS CSI 설치 문서][nfs-csi-install]를
따른다.

[nfs-csi-install]: https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.13.4.md

```bash
kubectl -n kube-system get pod -l app=csi-nfs-controller
kubectl -n kube-system get pod -l app=csi-nfs-node
kubectl get csidriver nfs.csi.k8s.io
```

### 2. NFS Server Pod와 PVC 실행

```bash
kubectl apply -f nfs-pod.yml
kubectl apply -f nfs-service.yml
kubectl apply -f nfs-storageclass.yml
kubectl apply -f nfs-pvc.yml
kubectl apply -f nfs-test-pod.yml
```

상태 확인:

```bash
kubectl get pod nfs-server nfs-pvc-test -o wide
kubectl get service nfs-server
kubectl get storageclass nfs-csi
kubectl get pvc nfs-test-pvc
```

PVC가 `Bound`가 되면 테스트 Pod에서 파일을 확인한다.

```bash
kubectl exec nfs-pvc-test -- cat /data/hello.txt
```

### 3. 실습 종료

```bash
kubectl delete -f nfs-test-pod.yml
kubectl delete -f nfs-pvc.yml
kubectl delete -f nfs-storageclass.yml
kubectl delete -f nfs-service.yml
kubectl delete -f nfs-pod.yml
```

`nfs-server` Pod는 `hostPath`를 사용하므로 실습용 구성이다. 서버 Pod가 실행되는
노드에 종속되며 고가용성을 제공하지 않는다.

- [`persistentvolume/`](./persistentvolume/): 실제 저장소 자원
- [`persistentvolumeclaim/`](./persistentvolumeclaim/): 애플리케이션의 저장소 요청
- [`storageclass/`](./storageclass/): 동적 볼륨 프로비저닝 정책

MariaDB StatefulSet의 `volumeClaimTemplates`는 이 개념을 Pod별 PVC 생성에
적용한 예제다. 현재 StatefulSet은 `nfs-csi` StorageClass를 사용한다.
