# 24. Kubernetes Rollout 확인

새 이미지가 적용된 뒤 Deployment의 rollout과 Pod 상태를 확인한다.

```bash
kubectl -n default set image deployment/fastcgi-backend \
  backend=jarrodkim/fastapi-backend:"$IMAGE_TAG"
kubectl rollout status deployment/fastcgi-backend --timeout=180s
kubectl get pods -l app=fastcgi-backend -o wide
```

격리된 테스트 네임스페이스를 사용할 때는 `NAMESPACE` 환경변수로 대상을
지정한다. 생략하면 `default`를 사용한다.

```bash
NAMESPACE=ci-verify bash ./practice-order/24-rollout/deploy.sh IMAGE:TAG
```

- [배포 스크립트](./deploy.sh)

배포가 완료되기 전에는 이전 ReplicaSet이 트래픽을 처리할 수 있다. readiness
상태와 애플리케이션 로그도 함께 확인한다.
