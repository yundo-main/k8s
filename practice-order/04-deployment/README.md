# Deployment

무상태 애플리케이션 Pod의 배포, 롤링 업데이트, 롤백과 스케일링을 관리한다.

## nginx Deployment 실습

`nginx.yml`은 `jarrodkim/nginx-test:latest` 컨테이너를 3개의 Pod로 실행하고,
Deployment가 ReplicaSet을 통해 원하는 복제본 수를 유지하도록 구성한 예제다.

구조와 배포 흐름:

![nginx Deployment 구조](./nginx.svg)

전체 예제: [`nginx.yml`](./nginx.yml)

### 배포 및 확인

```bash
kubectl apply -f nginx.yml
kubectl rollout status deployment/nginx-deployment
kubectl get deployment nginx-deployment
kubectl get rs -l app=nginx-deployment
kubectl get pods -l app=nginx-deployment -o wide
```

### 스케일링

```bash
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods -l app=nginx-deployment
```

### 롤백 확인

Deployment의 Pod 템플릿을 변경하면 새 ReplicaSet이 생성된다. 변경 후 문제가
있을 때 다음 명령으로 이전 리비전으로 되돌릴 수 있다.

```bash
kubectl rollout history deployment/nginx-deployment
kubectl rollout undo deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment
```

### 실습 종료

```bash
kubectl delete -f nginx.yml
```
