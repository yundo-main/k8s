# 클러스터 범위 오브젝트

Namespace, Node, 자원 제한, Lease 등 클러스터 운영 범위의 리소스를 관리한다.

## 기존 3-Tier 자원 제한 예제

[`3tier-limits.yml`](./3tier-limits.yml)은 현재 Namespace에 3-Tier 실습용
CPU·메모리·Pod 수 제한과 컨테이너 기본 자원값을 설정한다.

```bash
kubectl apply -f 3tier-limits.yml
```

현재 Namespace에 ResourceQuota와 LimitRange를 적용한다.

```bash
kubectl get resourcequota 3tier-quota
```

Namespace의 CPU·메모리·Pod 사용량과 제한량을 요약해 확인한다.

```bash
kubectl get limitrange 3tier-default-limits
```

컨테이너 기본 requests/limits를 설정하는 LimitRange를 확인한다.

```bash
kubectl describe resourcequota 3tier-quota
```

Quota의 상세 제한값과 현재 사용량을 확인한다.
