# Addon 설치 순서

기본 Kubernetes 설치가 끝난 뒤 실습에 필요한 Addon만 선택해 설치한다.
설치 실행은 [`install/playbooks/addons/README.md`](../playbooks/addons/README.md)의
Ansible Playbook을 사용한다. 이 디렉터리는 실제 `kubectl`·`curl` 기반 설치 및
제거 스크립트와 Addon별 선행조건·검증 기준을 관리한다.

## 1. 기본 클러스터 확인

```bash
export KUBECONFIG="$HOME/.kube/k8s-config"
```

현재 터미널에서 사용할 클러스터 접속 설정을 지정한다.

```bash
kubectl get nodes -o wide
```

모든 노드의 Ready 상태와 노드 IP·아키텍처를 확인한다.

```bash
kubectl get pods -A
```

모든 Namespace의 시스템 Pod 상태를 확인한다.

```bash
kubectl get --raw='/readyz?verbose'
```

Kubernetes API Server의 세부 준비 상태를 확인한다.

```bash
bash operations/01-cluster/check-architecture.sh
```

실행 환경의 CPU 아키텍처와 이미지 호환성을 점검한다.

모든 노드가 `Ready`이고 Calico·CoreDNS가 정상이어야 Addon 설치를 시작한다.
실습 이미지와 노드 아키텍처가 다르면 컨테이너가 `exec format error`로 실패할
수 있으므로 이미지 manifest도 확인한다.

## 2. Addon 설치·검증 순서

| 순서 | Addon | 필요한 실습 | 설치·검증 문서 |
| --- | --- | --- | --- |
| 1 | CNI·Calico | 01~18 전체 | `playbooks/addons/cni-calico.yml` · [운영 자료](../../operations/07-addons/cni/README.md) |
| 2 | NFS CSI (`csi-nfs` Namespace) | 08 Storage, 09 StatefulSet, 15 Backup | `playbooks/addons/nfs-csi.yml` · [운영 자료](../../operations/07-addons/storage/README.md) |
| 3 | NGINX Ingress Controller | 11 Ingress, 12 NetworkPolicy | `playbooks/addons/ingress-nginx.yml` · [운영 자료](../../operations/07-addons/ingress/README.md) |
| 4 | Metrics Server | 13 HPA | `playbooks/addons/metrics-server.yml` · [운영 자료](../../operations/07-addons/autoscaling/README.md) |
| 5 | Operator·Controller | 선택 고급 실습 | [운영 자료](../../operations/07-addons/operators/README.md) |

Calico는 기본 클러스터 설치 단계에서 먼저 설치할 수 있고, `addons/all.yml`을
사용하는 통합 경로에서도 첫 번째로 적용한다. NFS CSI, Ingress Controller,
Metrics Server는 선택형 Addon이므로 필요한 실습 전에 설치한다.

## 3. 설치 완료 판정

### CNI·Calico

```bash
kubectl -n calico-system get pods
```

Calico 구성 Pod가 정상 실행 중인지 확인한다.

### NFS CSI Pod

```bash
kubectl -n csi-nfs get pods
```

NFS CSI Driver 구성 Pod 상태를 확인한다.

### NFS CSI Driver 등록

```bash
kubectl get csidriver nfs.csi.k8s.io
```

클러스터에 NFS CSI Driver 리소스가 등록되었는지 확인한다.

### IngressClass

```bash
kubectl get ingressclass nginx
```

Ingress가 사용할 `nginx` IngressClass가 등록되었는지 확인한다.

### Ingress Controller Service

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

외부 접근에 사용할 Ingress Controller의 Service와 NodePort를 확인한다.

### Metrics API

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
```

Metrics Server APIService가 `Available=True`인지 확인한다.

### Node metrics

```bash
kubectl top nodes
```

노드 CPU·메모리 사용량을 조회해 Metrics Server가 실제로 응답하는지 확인한다.

해당 실습에 필요한 확인 항목이 준비되지 않았으면 실습 리소스를 적용하지
않는다. 현재 테스트 클러스터에는 NFS CSI Driver와 `IngressClass/nginx`가
설치되어 있다. Metrics Server 설치 여부는 13번 실습 전에 별도로 확인한다.

## 5. NGINX Ingress Controller 제거

설치된 NGINX Ingress Controller 전체를 제거할 때는 설치 스크립트의 반대 스크립트를
사용한다. `INGRESS_NGINX_VERSION`을 지정하지 않으면 설치 기본값인 `v1.15.1`을
사용한다.

```bash
bash install/addons/ingress/uninstall-ingress-nginx.sh
```

Controller Deployment, Service, RBAC, `IngressClass/nginx`, `ingress-nginx`
Namespace를 제거한다. 애플리케이션 Namespace의 `Ingress` 리소스는 삭제하지 않으므로
필요하면 해당 실습의 삭제 명령을 별도로 실행한다.

```bash
INGRESS_NGINX_VERSION=v1.15.1 \
  bash install/addons/ingress/uninstall-ingress-nginx.sh
```

설치할 때 사용한 버전과 다른 버전을 지정하면 실제 리소스와 manifest가 다를 수
있으므로, 설치 시 사용한 버전을 동일하게 지정한다.

## 4. 실습과의 연결

- 01~07: 기본 클러스터 확인 후 실행
- 08~09: NFS CSI 설치와 ARM64 호환 NFS 서버 이미지 확인 후 실행
- 10: Addon 없이 3-Tier 내부 통신부터 검증 가능
- 11~12: Ingress Controller와 Calico 정책 지원 확인 후 실행
- 13: Metrics Server 확인 후 HPA 적용
- 15: NFS PVC가 `Bound`이고 MariaDB가 Ready인 뒤 실행
