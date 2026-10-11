# Addon 설치 순서

기본 Kubernetes 설치가 끝난 뒤 실습에 필요한 Addon만 선택해 설치한다.
설치 실행은 [`install/playbooks/addons/README.md`](../playbooks/addons/README.md)의
Ansible Playbook을 사용한다. 이 문서는 Addon별 선행조건과 검증 기준을 설명한다.

## 1. 기본 클러스터 확인

```bash
export KUBECONFIG="$HOME/.kube/k8s-config"
kubectl get nodes -o wide
kubectl get pods -A
kubectl get --raw='/readyz?verbose'
bash operations/cluster/check-architecture.sh
```

모든 노드가 `Ready`이고 Calico·CoreDNS가 정상이어야 Addon 설치를 시작한다.
실습 이미지와 노드 아키텍처가 다르면 컨테이너가 `exec format error`로 실패할
수 있으므로 이미지 manifest도 확인한다.

## 2. Addon 설치·검증 순서

| 순서 | Addon | 필요한 실습 | 설치·검증 문서 |
| --- | --- | --- | --- |
| 1 | CNI·Calico | 01~18 전체 | `playbooks/addons/cni-calico.yml` · [운영 자료](../../operations/addons/cni/README.md) |
| 2 | NFS CSI (`csi-nfs` Namespace) | 08 Storage, 09 StatefulSet, 15 Backup | `playbooks/addons/nfs-csi.yml` · [운영 자료](../../operations/addons/storage/README.md) |
| 3 | NGINX Ingress Controller | 11 Ingress, 12 NetworkPolicy | `playbooks/addons/ingress-nginx.yml` · [운영 자료](../../operations/addons/ingress/README.md) |
| 4 | Metrics Server | 13 HPA | `playbooks/addons/metrics-server.yml` · [운영 자료](../../operations/addons/autoscaling/README.md) |
| 5 | Operator·Controller | 선택 고급 실습 | [운영 자료](../../operations/addons/operators/README.md) |

Calico는 기본 클러스터 설치 단계에서 먼저 설치할 수 있고, `addons.yml`을
사용하는 통합 경로에서도 첫 번째로 적용한다. NFS CSI, Ingress Controller,
Metrics Server는 선택형 Addon이므로 필요한 실습 전에 설치한다.

## 3. 설치 완료 판정

```bash
# CNI
kubectl -n calico-system get pods

# NFS CSI
kubectl -n csi-nfs get pods
kubectl get csidriver nfs.csi.k8s.io

# Ingress
kubectl get ingressclass nginx
kubectl -n ingress-nginx get svc ingress-nginx-controller

# Metrics Server
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
```

해당 실습에 필요한 확인 항목이 준비되지 않았으면 실습 리소스를 적용하지
않는다. 현재 테스트 클러스터에는 NFS CSI Driver와 `IngressClass/nginx`가
설치되어 있다. Metrics Server 설치 여부는 13번 실습 전에 별도로 확인한다.

## 4. 실습과의 연결

- 01~07: 기본 클러스터 확인 후 실행
- 08~09: NFS CSI 설치와 ARM64 호환 NFS 서버 이미지 확인 후 실행
- 10: Addon 없이 3-Tier 내부 통신부터 검증 가능
- 11~12: Ingress Controller와 Calico 정책 지원 확인 후 실행
- 13: Metrics Server 확인 후 HPA 적용
- 15: NFS PVC가 `Bound`이고 MariaDB가 Ready인 뒤 실행
