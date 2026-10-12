# 노드 상세 정보 확인

문서 이동: [노드 운영](./README.md) · [노드 목록 조회](./get-nodes.md) · [Taint 운영](./taint.md) · [다음: 워크로드 운영](../03-workloads/README.md)

특정 노드의 라벨, 조건, 할당 가능한 자원, Pod 목록, 이벤트를 확인한다.

```bash
kubectl describe node <노드이름>
```

예시:

```bash
kubectl describe node node-01
```

## 확인할 주요 영역

### Conditions

노드의 현재 상태를 확인한다.

- `Ready`: kubelet과 런타임이 정상인지 확인
- `MemoryPressure`: 메모리 부족 여부
- `DiskPressure`: 디스크 부족 여부
- `PIDPressure`: 프로세스 ID 부족 여부
- `NetworkUnavailable`: 노드 네트워크 사용 가능 여부

### Addresses

노드의 Hostname, InternalIP, ExternalIP를 확인한다.

### Capacity / Allocatable

- `Capacity`: 노드 전체 자원
- `Allocatable`: Kubernetes Pod에 할당 가능한 자원

### Non-terminated Pods

해당 노드에서 실행 중인 Pod와 자원 요청·제한을 확인한다.

### Events

노드 등록, 네트워크, 디스크, kubelet 관련 최근 이벤트를 확인한다.

```bash
kubectl describe node <노드이름> | sed -n '/Events:/,$p'
```

## 문제 점검 예시

```bash
kubectl get nodes
kubectl describe node <노드이름>
kubectl get pods -A -o wide --field-selector spec.nodeName=<노드이름>
kubectl get events --all-namespaces --sort-by=.lastTimestamp
```
