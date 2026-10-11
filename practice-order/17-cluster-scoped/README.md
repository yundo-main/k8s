# 클러스터 범위 오브젝트

Namespace, Node, 자원 제한, Lease 등 클러스터 운영 범위의 리소스를 관리한다.

## 기존 3-Tier 자원 제한 예제

[`3tier-limits.yml`](./3tier-limits.yml)은 현재 Namespace에 3-Tier 실습용
CPU·메모리·Pod 수 제한과 컨테이너 기본 자원값을 설정한다.

```bash
kubectl apply -f 3tier-limits.yml
kubectl get resourcequota 3tier-quota
kubectl get limitrange 3tier-default-limits
kubectl describe resourcequota 3tier-quota
```
