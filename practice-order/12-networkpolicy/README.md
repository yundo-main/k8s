# NetworkPolicy

Pod 간 ingress·egress 네트워크 허용 규칙을 정의한다. CNI가 NetworkPolicy를
지원해야 실제로 적용된다.

![3-Tier NetworkPolicy 허용 흐름](./networkpolicy-overview.svg)

현재 클러스터는 Calico CNI를 사용하므로 Kubernetes 표준 NetworkPolicy를
적용한다. 3-Tier 실습에서는 기본 통신을 차단한 뒤 필요한 경로만 허용한다.

정책 대상은 기존 10단계 3-Tier의 `frontend`, `fastcgi-backend`, `mariadb`
Pod이며, 별도의 애플리케이션을 생성하지 않는다.

## 3-Tier 정책

[`3tier-networkpolicy.yml`](./3tier-networkpolicy.yml)은 다음 통신만 허용한다.

```text
Ingress Controller → Frontend:80
Frontend → Backend:8000
Backend → MariaDB:3306
Frontend·Backend → kube-dns:53
```

정책 대상은 `app` 라벨이 `frontend`, `fastcgi-backend`, `mariadb`인 Pod다.

## 적용 순서

10단계 3-Tier와 11단계 Ingress가 정상 동작하는지 먼저 확인한 뒤 적용한다.

```bash
kubectl apply -f 3tier-networkpolicy.yml
kubectl get networkpolicy
kubectl describe networkpolicy 3tier-default-deny
```

정책 적용 후에도 외부 접근이 되는지 확인한다.

```bash
curl http://10.10.10.150:30198/
kubectl get pods -l app=frontend
kubectl get pods -l app=fastcgi-backend
kubectl get pods -l app=mariadb
```

정책이 적용된 뒤 연결이 차단되면 다음 항목을 확인한다.

- `ingress-nginx` Namespace에 `kubernetes.io/metadata.name` 라벨이 있는지
- CoreDNS Pod에 `k8s-app: kube-dns` 라벨이 있는지
- Frontend·Backend·MariaDB Pod의 `app` 라벨이 정책과 일치하는지
- Calico Node와 Typha Pod가 정상인지

```bash
kubectl get namespace ingress-nginx kube-system --show-labels
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n calico-system get pods
```

## 삭제

```bash
kubectl delete -f 3tier-networkpolicy.yml
```
