# 자동 확장 오브젝트

기존 10단계 3-Tier Backend를 기준으로 Probe, 수동 Scale, HPA, PDB,
PriorityClass를 적용한다.

![Backend Probe와 Scale 구조](./probe-scale-overview.svg)

## 예제 파일

- [`backend-operational.yml`](./backend-operational.yml): Probe·리소스·우선순위를
  포함한 Backend Deployment
- [`horizontalpodautoscaler/backend-hpa.yml`](./horizontalpodautoscaler/backend-hpa.yml): CPU 기반 자동 확장
- [`poddisruptionbudget/backend-pdb.yml`](./poddisruptionbudget/backend-pdb.yml): 자발적 중단 보호
- [`priorityclass/fastcgi-backend-priority.yml`](./priorityclass/fastcgi-backend-priority.yml): 스케줄링 우선순위

## 적용 순서

먼저 10단계 3-Tier의 ConfigMap, Secret, Service가 준비되어 있어야 한다.

```bash
kubectl apply -f ../10-3tier/backend.yml
kubectl apply -f priorityclass/fastcgi-backend-priority.yml
kubectl apply -f backend-operational.yml
kubectl apply -f poddisruptionbudget/backend-pdb.yml
```

`backend-operational.yml`은 기존 `fastcgi-backend` Deployment를 Probe와
PriorityClass가 포함된 운영형 예제로 갱신한다.

## 수동 Scale

```bash
kubectl scale deployment fastcgi-backend --replicas=2
kubectl get deployment,pod -l app=fastcgi-backend
kubectl scale deployment fastcgi-backend --replicas=1
```

## HPA 적용

Metrics Server가 동작해야 한다.

```bash
kubectl top pods
kubectl apply -f horizontalpodautoscaler/backend-hpa.yml
kubectl get hpa fastcgi-backend-hpa
kubectl describe hpa fastcgi-backend-hpa
```

## 확인 및 삭제

```bash
kubectl get pod -l app=fastcgi-backend
kubectl describe pod -l app=fastcgi-backend
kubectl get pdb fastcgi-backend-pdb
kubectl get priorityclass fastcgi-backend-high
```

```bash
kubectl delete -f horizontalpodautoscaler/backend-hpa.yml
kubectl delete -f poddisruptionbudget/backend-pdb.yml
kubectl delete -f backend-operational.yml
kubectl delete -f priorityclass/fastcgi-backend-priority.yml
```
