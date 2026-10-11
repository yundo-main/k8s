# 노드 목록 조회

## 기본 상태 확인

```bash
kubectl get nodes
```

주요 출력 항목:

| 항목 | 설명 |
|---|---|
| `NAME` | Kubernetes에 등록된 노드 이름 |
| `STATUS` | `Ready`, `NotReady` 등 노드 상태 |
| `ROLES` | `control-plane`, `worker` 역할 |
| `AGE` | 노드가 클러스터에 등록된 시간 |
| `VERSION` | 노드의 kubelet 버전 |

## 상세 네트워크 정보 확인

```bash
kubectl get nodes -o wide
```

추가로 다음 정보를 확인할 수 있다.

- `INTERNAL-IP`: 클러스터 내부 통신에 사용하는 노드 IP
- `EXTERNAL-IP`: 외부 접근용 IP. 없으면 `<none>`으로 표시
- `OS-IMAGE`: 노드 운영체제
- `KERNEL-VERSION`: Linux 커널 버전
- `CONTAINER-RUNTIME`: containerd 등 컨테이너 런타임

## 특정 노드 확인

```bash
kubectl get node <노드이름> -o wide
```

예시:

```bash
kubectl get node node-01 -o wide
```

노드 이름은 먼저 `kubectl get nodes`로 확인한다.
